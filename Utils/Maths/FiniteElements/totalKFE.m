function [m,U,K,F] = totalKFE( m, useGrowthTensors, useMorphogens )
%[m,U,K,F] = totalKFE( m, useGrowthTensors, useMorphogens )
%    Solve the FEM model for the mesh (volumetric meshes only).
%    The mesh already contains the temperature at each node and the residual
%    displacements of the nodes.  After the computation, the mesh will contain
%    the new positions of all the nodes.
%    The additional results are:
%    U: the displacements applied to all the nodes.  If the computation
%    fails in a manner that renders U non-meaningful, U will be returned as
%    empty.
%    K: The assembled K matrix for the FEM computation.
%    F: The assembled force vector for the FEM computation.
%    The mesh is additionally assumed to have the following components:
%    m.gaussInfo: the Gauss quadrature points for a single cell in isoparametric
%       coordinates, and the values and gradients of the shape functions at those points.
%    m.D: the compliance matrix in global coordinates.  This will
%        eventually be replaced by data per cell.
%    If useGrowthTensors is true (default is false) then growth
%    tensors have been specified for each cell.  Otherwise they are
%    calculated from the morphogens.

% Tasks remaining:
% 1. Implement per-cell anisotropic elastic and thermal moduli.
% 2. Experiment with tolerance to see how large we can set it and get
%    reasonable results.

    starttime = tic;
    SPLAT = false;
    NOSPLAT = true;

    verbose = true;
    U = [];
    K = [];
    F = [];
    
    if ~isVolumetricMesh(m)
        timedFprintf( 1, 'Only applicable to volumetric meshes and this mesh is foliate.\n' );
        return;
    end

    timedFprintf( 1, 'Beginning.\n' );
    global CANUSEGPUARRAY
    if nargin < 2, useGrowthTensors = false; end
    if nargin < 3, useMorphogens = ~useGrowthTensors; end
    full3d = usesNewFEs( m );

    requireK = nargout >= 3;
    requireF = nargout >= 4;
    
    sb = findStopButton( m );
    if full3d
        numnodes = size(m.FEnodes,1);
    else
        numnodes = size(m.prismnodes,1);
    end
    numFEs = getNumberOfFEs( m );
    vxsPerFE = getNumVxsPerFE( m );
    dfsPerNode = 3;
    dfsPerCell = vxsPerFE*dfsPerNode;
    numDFs = numnodes*dfsPerNode;
    vxsPerFE = getNumVxsPerFE( m );
    lengthOf6Tensor = getComponentsPerSymmetricTensor();
    m = makeTRIvalid( m );
    
    setGlobals();
    STRAINRET_MGEN = FindMorphogenRole( m, 'STRAINRET', false );
    
    locnode = m.globalDynamicProps.locatenode;
    locDFs = m.globalDynamicProps.locateDFs;
    dolocate = (locnode ~= 0) && any(locDFs);
    
    if userinterrupt( sb )
        m.displacements = [];
        U = [];
        timedFprintf( 1, 'Ending because simulation interrupted by user at step %d.\n', ...
            m.globalDynamicProps.currentIter );
        return;
    end

    SPARSE_LIMIT = 10000;  % Should be some value estimated from the result of memory(), or user-settable.
    useSparse = m.globalProps.alwayssparse || (numDFs >= SPARSE_LIMIT);
    timedFprintf( 1, 'Using %s matrices.\n', boolchar( useSparse, 'sparse', 'full' ) );
    useSingle = strcmp(m.globalProps.solverprecision,'single') && ~useSparse;
    if SPLAT
        if useSingle
            Kparts = zeros( dfsPerCell, dfsPerCell, numFEs, 'single' );
            Fparts = zeros( dfsPerCell, numFEs, 'single' );
        else
            Kparts = zeros( dfsPerCell, dfsPerCell, numFEs );
            Fparts = zeros( dfsPerCell, numFEs );
        end
        alldofs = zeros( dfsPerCell, numFEs );
    end
    if NOSPLAT
        if ~useSparse
            try
                if useSingle
                    K = zeros( numDFs, numDFs, 'single' );
                else
                    K = zeros( numDFs, numDFs );
                end
            catch err
                switch err.identifier
                    case 'MATLAB:nomem'
                        reason = ': not enough memory';
                    case 'MATLAB:pmaxsize'
                        reason = ': larger than allowed by Matlab';
                    otherwise
                        reason = err.message;
                end
                if m.globalProps.allowsparse
                    usingsparse = ['Using a sparse array instead.', newline];
                else
                    usingsparse = '';
                end
                timedFprintf( 1, 'Cannot allocate a %d by %d full array.\n%s\n%s', ...
                    numDFs, numDFs, reason, usingsparse );
                if m.globalProps.allowsparse
                    useSparse = true;
                else
                    timedFprintf( 1, 'Ending because memory cannot be allocated.\n' );
                    return;
                end
            end
        end
        if useSparse
            % In the next line, 4 is just an estimate.  The proper value for the
            % third argument is numDFs*dfsPerNode times the average number of nodes
            % in all the cells that a typical node is a member of.
            estimatedSpace = numDFs*dfsPerCell*4;
            % timedFprintf( 1, 'Allocating %d entries.\n', estimatedSpace );
            K = spalloc( numDFs, numDFs, estimatedSpace );
        end
        % We always allocate F as a full matrix, because it is far smaller than
        % K.
        if useSingle
            F = zeros( numDFs, 1, 'single' );
        else
            F = zeros( numDFs, 1 );
        end
    end
        
    ELIMINATERIGIDMOTION = false;
    EXACTINV = false;
    if ELIMINATERIGIDMOTION
        R = zeros( lengthOf6Tensor, numDFs );
        R( 1, 1:3:numDFs ) = 1;
        R( 2, 2:3:numDFs ) = 1;
        R( 3, 3:3:numDFs ) = 1;
        for i = 1:numnodes
            av = sum(m.prismnodes,1)/numnodes;
            x = m.prismnodes(i,1) - av(1);
            y = m.prismnodes(i,2) - av(2);
            z = m.prismnodes(i,3) - av(3);
            j = i*3;
            R([4 5 6],[j-2, j-1, j]) = [ [ 0 z -y ]; [ -z 0 x ]; [ y -x 0 ] ];
        end
      % R
        [xmin,n1] = min(m.prismnodes(:,1));
        [xmax,n2] = max(m.prismnodes(:,1));
        [ymax,n3] = max(m.prismnodes(:,2));
        n1 = n1*3;
        n2 = n2*3;
        n3 = n3*3;
        selectedDFs = [n1-2, n1-1, n1, n2-1, n2, n3];
    end

    if STRAINRET_MGEN==0
        residStrainPerStep = [];
    else
        strainretMgen = getEffectiveMgenLevels( m, STRAINRET_MGEN );
        sr = max( min( strainretMgen, 1 ), 0 );
        if m.globalProps.timestep==0
            % 0^0 is deemed to be 0, anything_else^0 is 1.
            residStrainPerStep = ones(size(sr));
            residStrainPerStep(sr==0) = 0;
        else
            residStrainPerStep = sr.^m.globalProps.timestep;
        end
    end
    if useMorphogens
        if m.globalProps.flatten
            m = makeZeroGrowthTensors( m );
        else
            m = makeMeshGrowthTensors( m );
        end
    end
    if userinterrupt( sb )
        U = abandon( m );
        return;
    end
    if m.globalDynamicProps.freezing <= 0
        retainedStrain = 0;
    elseif m.globalDynamicProps.freezing >= 1
        retainedStrain = 1;
    else
        retainedStrain = m.globalDynamicProps.freezing^m.globalProps.timestep;
        % exp( -m.globalProps.timestep*(1/m.globalDynamicProps.freezing - 1) );
    end
    appliedStrain = 1 - retainedStrain;
  % retainedStrain = retainedStrain/(1+appliedStrain) % Only valid if the applied strain
        % is released and there is no growth.  Properly we should dilute
        % the retained strain by the actual deformation.
    if m.globalProps.flatten || isempty( residStrainPerStep )
        residualScalePerFE = zeros( getNumberOfFEs( m ), 1 );
    else
        % residualScalePerFE = sum( reshape( residStrainPerStep(m.tricellvxs'), 3, [] )', 2 )/3;
        residualScalePerFE = sum( reshape( residStrainPerStep(m.FEsets(1).fevxs), [], vxsPerFE ), 2 )/vxsPerFE;
    end
    
    reportInterval = 10000;
    for ci=1:numFEs
        if SPLAT
            Kpart = zeros( dfsPerCell, dfsPerCell );
            Fpart = zeros( dfsPerCell, 1 );
        end
        gt1 = zeros(vxsPerFE,lengthOf6Tensor);
        if useGrowthTensors
            if size( m.celldata(ci).cellThermExpGlobalTensor, 2 )==1
                gt1 = gt1 + repmat( m.celldata(ci).cellThermExpGlobalTensor', vxsPerCell, 1 ) ...
                            * m.globalProps.timestep;
            else
                gt1 = gt1 + ([ repmat( m.celldata(ci).cellThermExpGlobalTensor(:,1)', 3, 1 ); ...
                               repmat( m.celldata(ci).cellThermExpGlobalTensor(:,2)', 3, 1 ) ]) ...
                            * m.globalProps.timestep;
            end
            if ~isempty(m.directGrowthTensors)
                gt1 = gt1 + repmat( m.directGrowthTensors(ci,:), vxsPerCell, 1 ) * m.globalProps.timestep;
            end
        end
        if useMorphogens
            gt1 = gt1 + m.celldata(ci).Gglobal * m.globalProps.timestep;
        end
        % Every row of gt1 is a growth tensor, one row for every vertex.
        eps0 = -gt1';
        % Every column of eps0 is a growth tensor, one column for every vertex.
%         if m.globalProps.flatten
%             residualScale = 1;
%         else
%             residualScale = sum(residStrainPerStep(m.tricellvxs(ci,:)))/3;
%         end
      % if residualScale ~= 1
      %     m.celldata(ci).residualStrain = m.celldata(ci).residualStrain * residualScale;
      % end
        cellvxs = m.FEsets(1).fevxs( ci, : );
        cellvxCoords = m.FEnodes( cellvxs, : );
        [m.celldata(ci),k1,f1] = ...
            cellFEM_FE( m.celldata(ci), ...
                        m.FEsets(1).fe, ...
                        cellvxCoords, ...
                        m.cellstiffness(:,:,ci), ...
                        eps0, ...
                        residualScalePerFE(ci), ...
                        m.celldata(ci).residualStrain );
        if any(isnan(k1(:))) || any(isnan(f1))
            m.displacements(:) = [];
            U = [];
            timedFprintf( 1, 'Ending: growth cannot be calculated due to singularities.\n' );
            return;
        end
        dfBase = cellvxs*3;
        newIndexes = reshape( [ dfBase-2; dfBase-1; dfBase ], 1, [] );
        
        if SPLAT
            alldofs(:,ci) = newIndexes;
            Kparts(:,:,ci) = k1;
            Fparts(:,ci) = -f1;
        end
        if NOSPLAT
            K( newIndexes, newIndexes ) = K( newIndexes, newIndexes ) + k1;
            F( newIndexes ) = F( newIndexes ) - f1;
        end
        
        if mod(ci,reportInterval)==0
            timedFprintf( 1, 'Building matrix, processed %d of %d elements.\n', ci, numFEs );
            if userinterrupt( sb )
                U = abandon( m );
                return;
            end
        end
    end
    
    if SPLAT
        alldof1 = reshape( repmat( alldofs, dfsPerCell, 1 ), [], 1 );
        alldof2 = reshape( repmat( alldofs(:)', dfsPerCell, 1 ), [], 1 );
        if useSparse
            K1 = sparse( alldof1, alldof2, Kparts(:), numDFs, numDFs );
            F1 = sparse( alldofs(:), 1, Fparts(:), numDFs, 1 );
        else
            K1 = accumarray( [alldof1, alldof2], Kparts(:), [numDFs, numDFs] );
            F1 = accumarray( alldofs(:), Fparts(:), [numDFs, 1] );
        end
    end
    
    if SPLAT
        if NOSPLAT
            Kerr = max(abs(K(:)-K1(:)))
            Ferr = max(abs(F-F1))
        else
            K = K1;
            F = F1;
        end
    end
    
    elapsedtime = toc(starttime);
    timedFprintf( 1, 'New method constructs matrices in %f seconds.\n', elapsedtime );
    
    if ELIMINATERIGIDMOTION
      % rR = rank(R)
      % rK = rank(K)
      % rKR = rank([K;R])
        K(selectedDFs,:) = K(selectedDFs,:) + R;
      % F(selectedDFs) = 0;
      % rKR = rank(K)
    end
    fixedMoves = [];
    stitchPairs = zeros(0,2);
    
    fixedDFmap = m.fixedDFmap;
    nodesWithFixedDFs = any( fixedDFmap, 2 );
    oneFixedNode = find( nodesWithFixedDFs, 2 );
    if length(oneFixedNode)==1
        % When there is just a single node having any fixed degrees of
        % freedom, we implement it not by eliminating equations, but by
        % rigidly translating the mesh afterwards.
        oneFixedDFs = fixedDFmap( oneFixedNode, : );
        if m.globalProps.twoD
            fixedDFmap( oneFixedNode, : ) = false;
        else
            fixedDFmap( oneFixedNode, : ) = false;
        end
    else
        oneFixedNode = [];
    end
    fixedDFs = find( reshape( fixedDFmap', [], 1 ) );
    [K,F,renumber] = eliminateEquations( K, F, fixedDFs );
    
    if userinterrupt( sb )
        m.displacements(:) = [];
        U = [];
        timedFprintf( 1, 'Ending because simulation interrupted by user at step %d.\n', ...
            m.globalDynamicProps.currentIter );
        return;
    end
    
    cgmaxiter = size(K,1)*10; % size(K,1)*40;
    if EXACTINV
        UC = inv(K)*F;
        cgflag = 0;
        cgrelres = 0;
        m.globalProps.cgiters = 0;
    else
        sparseSolve = true;
        switch m.globalProps.solver
            case 'cgs'
                USERANDOMDISPLACEMENTS = true;
                if USERANDOMDISPLACEMENTS
                    if isempty( m.displacements ) ...
                            || (~m.globalProps.usePrevDispAsEstimate) ...
                            || (m.globalDynamicProps.currentIter <= 0) ...
                            || all(m.displacements(:)==0)
                        timedFprintf( 1, 'Using random displacement as initial guess.\n' );
                        initestimate = randomiseDisplacements( m );
                    else
                        timedFprintf( 1, 'Using previous displacement as initial guess.\n' );
                        initestimate = reshape( m.displacements', [], 1 );
                        if m.globalProps.resetRand
                            rng(5489,'twister');  % rand('twister',5489);
                        end
                        initestimate = initestimate .* ...
                            (1 - m.globalProps.perturbRelGrowthEstimate/2 ...
                             + m.globalProps.perturbRelGrowthEstimate * rand( size(initestimate) ));
                          % (0.995 + 0.01*rand( size(initestimate) ));
                      % initestimate = initestimate( randperm( length(initestimate) ) );
                    end
                else
                    initestimate = zeros(numel(m.fixedDFmap),1);
                end
                if ~isempty(renumber)
                    initestimate = initestimate(renumber);
                end
                timedFprintf( 1, 'Growth: ' );
                USEJACKET = false;
              % solvertolerancemethod = m.globalProps.solvertolerancemethod
                if CANUSEGPUARRAY
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mycgs(gpuArray(K),gpuArray(F), ...
                              m.globalProps.solvertolerance, ...
                              m.globalProps.solvertolerancemethod, ...
                              cgmaxiter, ...
                              m.globalProps.maxsolvetime, ...
                              initestimate, ...
                              verbose, ...
                              @teststopbutton, ...
                              m);
                    UC = gather( UC );
                    timedFprintf( 1, 'Computation time for growth (cgs,full,GPUArray) is %.6f seconds.\n', toc(starttic) );
                elseif USEJACKET
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mycgs(single(K),F, ...
                              m.globalProps.solvertolerance, ...
                              m.globalProps.solvertolerancemethod, ...
                              cgmaxiter, ...
                              m.globalProps.maxsolvetime, ...
                              initestimate, ...
                              verbose, ...
                              @teststopbutton, ...
                              m);
                    timedFprintf( 1, 'Computation time for growth (cgs,full,single,JACKET) is %.6f seconds.\n', toc(starttic) );
                elseif sparseSolve || useSparse
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mycgs(sparse(K),F, ...
                              m.globalProps.solvertolerance, ...
                              m.globalProps.solvertolerancemethod, ...
                              cgmaxiter, ...
                              m.globalProps.maxsolvetime, ...
                              initestimate, ...
                              verbose, ...
                              @teststopbutton, ...
                              m);
                    timedFprintf( 1, 'Computation time for growth (cgs,sparse,double) is %.6f seconds.\n', toc(starttic) );
                else
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mycgs(K,F, ...
                              m.globalProps.solvertolerance, ...
                              m.globalProps.solvertolerancemethod, ...
                              cgmaxiter, ...
                              m.globalProps.maxsolvetime, ...
                              initestimate, ...
                              verbose, ...
                              @teststopbutton, ...
                              m);
                    timedFprintf( 1, 'Computation time for growth (cgs,full,double) is %.6f seconds.\n', toc(starttic) );
                end
              % if false && m.globalProps.usePrevDispAsEstimate
              %     testestimate = (UC-initestimate)./initestimate;
              % end
            case 'lsqr'
                if useSparse
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mylsqr(sparse(K),F, ...
                               m.globalProps.solvertolerance, ...
                               cgmaxiter, ...
                               m.globalProps.maxsolvetime);
                    timedFprintf( 1, 'Computation time for growth (lsqr,sparse,double) is %.6f seconds.\n', toc(starttic) );
                else
                    starttic = tic;
                    [UC,cgflag,cgrelres,m.globalProps.cgiters] = ...
                        mylsqr(K,F, ...
                               m.globalProps.solvertolerance, ...
                               cgmaxiter, ...
                               m.globalProps.maxsolvetime);
                    timedFprintf( 1, 'Computation time for growth (lsqr,full,double) is %.6f seconds.\n', toc(starttic) );
                end
            case 'dgelsy'
                UC = F;
                timedFprintf( 1, 'Growth by %s, size %d ... ', m.globalProps.solver, size(K,1) );
                starttic = tic;
                C = test_gels( K, UC );
                timedFprintf( 1, 'Computation time for growth (dgelsy,full,double) is %.6f seconds.\n', toc(starttic) );
                cgflag = 0;
                cgrelres = 0;
                m.globalProps.cgiters = 0;
            case 'culaSgesv'
                starttic = tic;
                [C,UC] = use_culaSgesv( K, F );
                timedFprintf( 1, 'Computation time for growth (culaSgesv,full,double) is %.6f seconds.\n', toc(starttic) );
                if C ~= 0
                    cgflag = -1;
                    switch C
                        case 0
                            culaerr = 'No error';
                        case 1
                            culaerr = 'CULA has not been initialized';
                        case 2
                            culaerr = 'No hardware is available to run';
                        case 3
                            culaerr = 'CUDA runtime or driver is not supported';
                        case 4
                            culaerr = 'Available GPUs do not support the requested operation';
                        case 5
                            culaerr = 'There is insufficient memory to continue';
                        case 6
                            culaerr = 'The requested feature has not been implemented';
                        case 7
                            culaerr = 'An invalid argument was passed to a function';
                        case 8
                            culaerr = 'An operation could not complete because of singular data';
                        case 9
                            culaerr = 'A blas error was encountered';
                        case 10
                            culaerr = 'A runtime error has occurred';
                    end
                    timedFprintf( 1, 'CULA error %d: %s.\n', C, culaerr );
                    UC = zeros( size(UC), 'double' );
                else
                    UC = double(UC);
                end
                cgflag = 0;
                cgrelres = 0;
                m.globalProps.cgiters = 0;
            otherwise
                complain( 'Warning: unknown solver "%s".  Elasticity equations not solved.', ...
                    m.globalProps.solver );
        end
    end
    U = insertFixedDFS( UC, renumber, numDFs, ...
        fixedDFs, [], m.globalDynamicProps.stitchDFs, [], [], fixedMoves );
    if requireK
            % Warning: insertFixedDFS2 only uses the first three arguments,
            % therefore it will not be correct if there is any stitching,
            % opposite pairs, or fixed moves.
        K = insertFixedDFS2( K, renumber, numDFs, m.globalDynamicProps.stitchDFs, [], [] );
      % KUF = (K*U - F)'
    end
    if requireF
        F = insertFixedDFS( F, renumber, numDFs, ...
            m.globalDynamicProps.stitchDFs, [], stitchPairs, [], [], fixedMoves );
    end
    U = reshape(U, dfsPerNode, numnodes )';
    if requireF
        F = reshape(F, dfsPerNode, numnodes )';
    end
    if cgflag ~= 0
        timedFprintf( 1, 'CGS error: ' );
        if cgflag==20
            fprintf( 1, 'CGS failed to converge to tolerance %g after %d seconds, %d of %d iterations.\n', ...
                cgrelres, round(m.globalProps.maxsolvetime), m.globalProps.cgiters, cgmaxiter );
        elseif cgflag==21
            fprintf( 1, 'CGS blew up after %d seconds, %d of %d iterations.\n', ...
                round(m.globalProps.maxsolvetime), m.globalProps.cgiters, cgmaxiter );
        elseif cgflag==8
            fprintf( 1, 'CGS interrupted by user after %d steps.\n', ...
                m.globalProps.cgiters );
        elseif cgflag > 0
            cgsmsg( cgflag,cgrelres,m.globalProps.cgiters,cgmaxiter );
        end
    end
    
  % stitchNodes = m.nodes( (m.globalDynamicProps.stitchDFs{1}-1)/3+1, : )
    if cgflag==8
        % User interrupt.  The displacements might not be meaningful.
        U = [];
        m.displacements(:) = [];
    else
        if m.globalProps.canceldrift
            anyfixed = any( m.fixedDFmap, 1 );
            [w,U] = cancelMoment( m.prismnodes, U, ~anyfixed );
        end
    
        U = U*appliedStrain;

        if CANUSEGPUARRAY
            U = gather(U);
        end
        if ~isempty(oneFixedNode)
            translation = -U( oneFixedNode, : );
            translation( ~oneFixedDFs ) = 0;
            U = U + repmat( translation, size( U, 1 ), 1 );
        end
        if dolocate
            translation = -U(locnode,:);
            translation( ~locDFs ) = 0;
            m.auxdata.locateTranslation = translation;
            U = U + repmat( translation, size( U, 1 ), 1 );
        end
        m.displacements = U;
        m = computeResiduals( m, retainedStrain );
    end
    
    if nargout < 2
        clear U;
    end
    if nargout < 3
        clear K;
    end
    if nargout < 4
        clear F;
    end
    
    timedFprintf( 1, 'Ending.\n' );
end

function U = abandon( m )
    m.displacements(:) = [];
    U = [];
    timedFprintf( 1, 'Ending because simulation interrupted by user at step %d.\n', ...
        m.globalDynamicProps.currentIter );
end
