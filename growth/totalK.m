function [m,U,K,F] = totalK( m, useGrowthTensors, useMorphogens )
%[m,U,K,F] = totalK( m, useGrowthTensors, useMorphogens )
%    Solve the FEM model for the mesh.
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

% This procedure is for traditional meshes, and can use either old-style
% computation or new-style FEs, according to the setting of the global
% gUSENEWFES_ELAST.

    verbose = true;
    U = [];
    K = [];
    F = [];
    
    global CANUSEGPUARRAY gUSENEWFES_ELAST
    if nargin < 2, useGrowthTensors = false; end
    if nargin < 3, useMorphogens = ~useGrowthTensors; end

    requireK = nargout >= 3;
    requireF = nargout >= 4;
    
    sb = findStopButton( m );

    cptsPerTensor = getComponentsPerSymmetricTensor();
    vxsPerCell = getNumVxsPerFE(m);
  % numGaussPoints = 6;
    dfsPerNode = 3;
    dfsPerCell = vxsPerCell*dfsPerNode;
    numnodes = size( m.prismnodes, 1 );
    numcells = size( m.tricellvxs, 1 );
    numDFs = numnodes*dfsPerNode;
    m = makeTRIvalid( m );
    
    setGlobals();
    STRAINRET_MGEN = FindMorphogenRole( m, 'STRAINRET' );
    
    locnode = m.globalDynamicProps.locatenode;
    locDFs = m.globalDynamicProps.locateDFs;
    dolocate = (locnode ~= 0) && any(locDFs);
    
    if userinterrupt( sb )
        m.displacements = [];
        U = [];
        timedFprintf( 1, 'Simulation interrupted by user at step %d.\n', ...
            m.globalDynamicProps.currentIter );
        return;
    end

    SPARSE_LIMIT = 10000;  % Should be some value estimated from the result of memory(), or user-settable.
    useSparse = m.globalProps.alwayssparse || (numDFs >= SPARSE_LIMIT);
    % Sparse arrays must be doubles.
    useSingle = strcmp(m.globalProps.solverprecision,'single') && ~useSparse;
    if ~useSparse
        try
            if useSingle
                timedFprintf( 1, 'Allocating single K: %d dfs.\n', numDFs );
                K = zeros( numDFs, numDFs, 'single' );
            else
                timedFprintf( 1, 'Allocating double K: %d dfs.\n', numDFs );
                K = zeros( numDFs, numDFs );
            end
        catch err
            switch err.identifier
                case 'MATLAB:nomem'
                    reason = ': not enough memory';
                case 'MATLAB:pmaxsize'
                    reason = ': larger than allowed by Matlab';
                otherwise
                    reason = '';
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
                return;
            end
        end
    end
    if useSparse
        % In the next line, 4 is just an estimate.  The proper value for the
        % third argument is numDFs*dfsPerNode times the average number of nodes
        % in all the cells that a typical node is a member of.
        estimatedSpace = numDFs*dfsPerCell*4;
        timedFprintf( 1, 'Allocating sparse K: %d space.\n', estimatedSpace );
        K = spalloc( numDFs, numDFs, estimatedSpace );
    end
    if useSingle
        timedFprintf( 1, 'Allocating single F: %d dfs.\n', numDFs );
        F = zeros( numDFs, 1, 'single' );
    else
        timedFprintf( 1, 'Allocating double F: %d dfs.\n', numDFs );
        F = zeros( numDFs, 1 );
    end
    timedFprintf( 1, 'Allocated K and F.\n' );
        
    ELIMINATERIGIDMOTION = false;
    ELIMINATE_UNBALANCED_FORCE = true;
    EXACTINV = false;
    if ELIMINATERIGIDMOTION
        R = zeros( 6, numDFs );
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
        residStrainPerStep = zeros( getNumberOfVertexes(m), 1 );
    else
        strainretMgen = getEffectiveMgenLevels( m, STRAINRET_MGEN );
        sr = max( min( strainretMgen, 1 ), 0 );
        if m.globalProps.timestep==0
            % 0^0 is deemed to be 0, anything_else^0 is 1.
            residStrainPerStep = double(sr>0);
        elseif all(sr==0)
            residStrainPerStep = zeros(size(sr));
        elseif all(sr==1)
            residStrainPerStep = ones(size(sr));
        else
            residStrainPerStep = sr.^m.globalProps.timestep;
        end
    end
    if useMorphogens
        if m.globalProps.flatten || hasZeroGrowth( m )
            m = makeZeroGrowthTensors( m );
        else
            m = makeMeshGrowthTensors( m );
        end
    end
    if userinterrupt( sb )
        m.displacements(:) = [];
        U = [];
        timedFprintf( 1, 'Simulation interrupted by user at step %d.\n', ...
            m.globalDynamicProps.currentIter );
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
    residualScalePerFE = sum( reshape( residStrainPerStep(m.tricellvxs'), 3, [] ), 1 )'/3;
    fe = FiniteElementType.MakeFEType('P6');
%     TEST_K = zeros(18,18,numcells);
%     TEST_F = zeros(18,numcells);
    timedFprintf( 1, 'Assembling K and F.\n' );
    if ~isfield( m.globalDynamicProps, 'pressure' )
        m.globalDynamicProps.pressure = 0;
    end
    pressure = m.globalDynamicProps.pressure;
    for ci=1:numcells
        gt1 = zeros(vxsPerCell,cptsPerTensor);
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
        % Every row of gt1 is a growth tensor.
        eps0 = -gt1';
        % Every column of eps0 is a growth tensor.
        trivxs = m.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        cellvxCoords = m.prismnodes( prismvxs, : );
        if size(m.cellstiffness,3)==1
            cs = m.cellstiffness;
        else
            cs = m.cellstiffness(:,:,ci);
        end

        if gUSENEWFES_ELAST
            CHECK_FE_METHOD = false;
            if CHECK_FE_METHOD
                [cd,k1,f1] = ...
                    cellFEM( m.celldata(ci), ...
                             cellvxCoords', ...
                             m.globalProps.gaussInfo, ...
                             cs, ...
                             eps0, ...
                             residualScalePerFE(ci), ...
                             pressure );
            end
            [m.celldata(ci),k,f] = ...
                cellFEM_FE( m.celldata(ci), ...
                            fe, ...
                            cellvxCoords, ...
                            cs, ...
                            eps0, ...
                            residualScalePerFE(ci), ...
                            m.celldata(ci).residualStrain, ...
                            pressure );
            if CHECK_FE_METHOD
                errk = max(abs(k1(:)-k(:)));
                errf = max(abs(f1(:)-f(:)));
                % These should both be zero to within rounding error (at
                % most a few times 1e-15).
                timedFprintf( 1, 'errk %g, errf %g\n', errk, errf );
            end
        else
            [m.celldata(ci),k,f] = ...
                cellFEM( m.celldata(ci), ...
                         cellvxCoords', ...
                         m.globalProps.gaussInfo, ...
                         cs, ...
                         eps0, ...
                         residualScalePerFE(ci), ...
                         pressure );
        end
%         TEST_K(:,:,ci) = k;
%         TEST_F(:,ci) = f;
        if any(isnan(k(:))) || any(isnan(f))
            m.displacements(:) = [];
            U = [];
            timedFprintf( 1, 'Growth cannot be calculated due to singularities.\n' );
            return;
        end
        dfBase = prismvxs*3;
        newIndexes = reshape( [ dfBase-2; dfBase-1; dfBase ], 1, [] );
%         timedFprintf( 1, 'Inserting element %d into K and F.\n', ci );
        K( newIndexes, newIndexes ) = K( newIndexes, newIndexes ) + k;
        F( newIndexes ) = F( newIndexes ) - f;
%         timedFprintf( 1, 'Inserted element %d into K and F.\n', ci );
        
        if mod(ci,1000)==0
            timedFprintf( 1, 'Processed %d elements.\n', ci );
        end
    end
    timedFprintf( 1, 'Assembled K and F.\n' );
    if ELIMINATERIGIDMOTION
      % rR = rank(R)
      % rK = rank(K)
      % rKR = rank([K;R])
        K(selectedDFs,:) = K(selectedDFs,:) + R;
      % F(selectedDFs) = 0;
      % rKR = rank(K)
    end
    if ELIMINATE_UNBALANCED_FORCE
        meanforce = mean( reshape( F, dfsPerNode, numnodes ), 2 );
        if norm(meanforce) > 0.001
            timedFprintf( 'Unbalanced force, total [ %g, %g, %g ], magnitude %g.\n', meanforce*numnodes, norm(meanforce)*numnodes );
        end
        meanforce = repmat( meanforce, numnodes, 1 );
        F = F - meanforce;
    end
    oneFixedNode = [];
    oneFixedDFs = [];
    if ~m.globalProps.flatten
        fixedDFmap = m.fixedDFmap;
        if m.globalProps.twoD
            xaxis = m.globalInternalProps.flataxes(1);
            yaxis = m.globalInternalProps.flataxes(2);
            flataxis = m.globalInternalProps.flataxes(3);
            % True flatness.  No vertex moves in the flat axis direction.
            fixedDFmap(:,flataxis) = true;
            % Ensure that matching vertexes of prismnodes have the same
            % displacement in the other two axes.
            stitchPairs = [ (xaxis:6:numDFs)' ((xaxis+3):6:numDFs)'; (yaxis:6:numDFs)' ((yaxis+3):6:numDFs)' ];
            prismNodesWithFixedDFs = any( fixedDFmap(:,[xaxis,yaxis]), 2 );
        else
            stitchPairs = [];
            prismNodesWithFixedDFs = any( fixedDFmap, 2 );
        end
        oneFixedMidplaneNode = [];
        oneFixedNode = find( prismNodesWithFixedDFs );
        if length(oneFixedNode)==1
            oneFixedDFs = fixedDFmap( oneFixedNode, : );
            if m.globalProps.twoD
                fixedDFmap( oneFixedNode, : ) = false;
            else
                fixedDFmap( oneFixedNode, : ) = false;
            end
        elseif m.globalProps.twoD ...
               && (length(oneFixedNode)==2) ...
               && (oneFixedNode(2) == oneFixedNode(1)+1) ...
               && (mod(oneFixedNode(2),2)==0)
            % Two fixed prism nodes corresponding to one midplane node.
            oneFixedMidplaneNode = oneFixedNode(2)/2;
            fixedDFmap( oneFixedNode, : ) = false;
        else
            oneFixedNode = [];
        end
        fixedDFs = find( fixedDFmap' );
        if m.globalProps.twoD
            oppositePairs = zeros(0,2);
            rowsToFix = [];
            fixedMoves = [];
            timedFprintf( 1, 'Eliminating fixed DFs for twoD mesh.\n' );
            [K,F,renumber] = eliminateEquations( K, F, ...
                fixedDFs, m.globalDynamicProps.stitchDFs, oppositePairs, stitchPairs, rowsToFix, fixedMoves );
        else % Opposite prism vertexes are allowed to move equally and oppositely.
            lowerDFs = reshape( ...
                fixedDFs( mod( fixedDFs-1, 6 ) < 3 ), [], 1 );
            upperDFs = lowerDFs + 3;
            oppositePairs = [ lowerDFs, upperDFs ];
          % RATE = 1;
            if true
                % Eventually these will be user-accessible.
                % rowsToFix and fixedMoves specify the degrees
                % of freedom which are to take specified values, and the
                % values they are to take.
                if isempty(m.drivennodes)
                    rowsToFix = [];
                    fixedMoves = [];
                else
                    rowsToFix = repmat( m.drivennodes(:)'*6, 6, 1 ) ...
                                + repmat( [-5;-4;-3;-2;-1;0], 1, length(m.drivennodes) );
                    rowsToFix = rowsToFix(:);
                    nodemoves = m.drivenpositions - m.nodes(m.drivennodes,:);
                    fixedMoves = repmat( nodemoves', 2, 1 );
                    fixedMoves = fixedMoves(:);
                end
            else
                fixedMovesMap = false( size( m.nodes, 1 ), 1 );
                rowsToFix = repmat( 6*[15 21 22 28 29 35], 6, 1 ) + repmat( [-5;-4;-3;-2;-1;0], 1, 6 );
                rowsToFix = rowsToFix(:);
                fixedMoves = -repmat( [[-1;0;0;-1;0;0], [1;0;0;1;0;0]], 1, 3 );
                fixedMoves = m.globalProps.timestep*fixedMoves(:); % zeros( size( rowsToFix, 1 ), 1 );
            end
            timedFprintf( 1, 'Eliminating fixed DFs.\n' );
            [K,F,renumber] = eliminateEquations( K, F, ...
                fixedDFs, m.globalDynamicProps.stitchDFs, oppositePairs, stitchPairs, rowsToFix, fixedMoves );
        end
    end
    if userinterrupt( sb )
        m.displacements(:) = [];
        U = [];
        timedFprintf( 1, 'Simulation interrupted by user at step %d.\n', ...
            m.globalDynamicProps.currentIter );
        return;
    end
    if any(isnan(K(:))) || any(isnan(F))
        m.displacements(:) = [];
        U = [];
        timedFprintf( 1, 'Growth cannot be calculated due to singularities.\n' );
        return;
    end
    
    cgmaxiter = size(K,1)*10; % size(K,1)*40;
    if all(F==0)
        UC = zeros(size(F));
        cgflag = 0;
        cgrelres = 0;
        m.globalProps.cgiters = 0;
    elseif strcmp( m.globalProps.solver, 'inv' )
        UC = K\F;
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
                            rng(5489,'twister');
                        end
                        initestimate = initestimate .* ...
                            (1 - m.globalProps.perturbRelGrowthEstimate/2 ...
                             + m.globalProps.perturbRelGrowthEstimate * rand( size(initestimate) ));
                          % (0.995 + 0.01*rand( size(initestimate) ));
                      % initestimate = initestimate( randperm( length(initestimate) ) );
                    end
                else
                    initestimate = zeros(numel(fixedDFmap),1); %#ok<UNRCH>
                end
                initestimate(oppositePairs(:,1)) = ...
                    (initestimate(oppositePairs(:,1))-initestimate(oppositePairs(:,2)));
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
                    starttic = tic; %#ok<UNRCH>
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
                C = test_gels( K, UC ); %#ok<NASGU>
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
                    cgflag = 0;
                    UC = double(UC);
                end
                cgrelres = 0;
                m.globalProps.cgiters = 0;
            otherwise
                complain( '%s: Warning: unknown solver "%s".  Elasticity equations not solved.', ...
                    datestring(), m.globalProps.solver );
        end
    end
    timedFprintf( 1, 'Growth equations solved.\n' );
    if m.globalProps.flatten
        U = UC;
    else
        timedFprintf( 1, 'Inserting fixed DFs.\n' );
        U = insertFixedDFS( UC, renumber, numDFs, ...
            m.globalDynamicProps.stitchDFs, oppositePairs, stitchPairs, [], rowsToFix, fixedMoves );
        if requireK
            % Warning: insertFixedDFS2 only uses the first three arguments,
            % therefore it will not be correct if there is any stitching,
            % opposite pairs, or fixed moves.
            K = insertFixedDFS2( K, renumber, numDFs, m.globalDynamicProps.stitchDFs, oppositePairs, [] );
          % KUF = (K*U - F)'
        end
        if requireF
            F = insertFixedDFS( F, renumber, numDFs, ...
                m.globalDynamicProps.stitchDFs, oppositePairs, stitchPairs, [], rowsToFix, fixedMoves );
        end
    end
    U = reshape(U, dfsPerNode, numnodes )';
    if requireF
        F = reshape( F, dfsPerNode, numnodes )';
    end
    if cgflag ~= 0
        timedFprintf( 1, 'cgs error: ' );
        if cgflag==20
            timedFprintf( 1, 'CGS failed to converge to tolerance %g after %d seconds, %d of %d iterations.\n', ...
                cgrelres, round(m.globalProps.maxsolvetime), m.globalProps.cgiters, cgmaxiter );
        elseif cgflag==8
            timedFprintf( 1, 'CGS interrupted by user after %d steps.\n', ...
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
            if m.globalProps.twoD
                rotaxis = m.globalInternalProps.flataxes(3);
            else
                rotaxis = [];
            end
            anyfixed = any( fixedDFmap, 1 );
            [~,U] = cancelMoment( m.prismnodes, U, ~anyfixed, rotaxis );
        end
    
        U = U*appliedStrain;

        if CANUSEGPUARRAY
            U = gather(U);
        end
        if ~isempty(oneFixedMidplaneNode)
            ptranslation = -U( oneFixedNode, : );
            translation = sum(ptranslation,1)/2;
        elseif ~isempty(oneFixedNode)
            translation = -U( oneFixedNode, : );
        end
        if ~isempty(oneFixedNode)
            translation( ~oneFixedDFs ) = 0;
            U = U + repmat( translation, size( U, 1 ), 1 );
        end
        if dolocate
            locpnode = locnode+locnode;
            translation = -(U(locpnode-1,:) + U(locpnode,:))/2;
            translation( ~locDFs ) = 0;
            U = U + repmat( translation, size( U, 1 ), 1 );
        end

        m.displacements = U;
        m = computeResiduals( m, retainedStrain );
        
        [m,result] = invokeIFcallback( m, 'ModifyDisplacements' );
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
    timedFprintf( 1, 'Completed.\n' );
end
