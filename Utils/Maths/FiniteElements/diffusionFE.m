function temperatures = diffusionFE( nodecoords, cellvertexes, fe, conductivity, ...
    absorption, production, temperatures, dt, fixednodes, ...
    tolerance, tolerancemethod, maxtime, perturbation, m )
%temperatures = tempdiff( nodecoords, cellvertexes, conductivity, ...
%        absorption, production, temperatures, transportfield, dt, ...
%        lengthscale, fixednodes, cellareas )
%    Perform a finite-element computation of thermal diffusion.
%    nodecoords is a numnodes*3 array of coordinates.
%    cellvertexes is a numFEs*K array of node indexes: each row
%        lists the node indexes of the vertices of the cell.
%    conductivity is one of the following:
%       * A single number.  This is the uniform isotropic thermal
%         conductivity (divided by the specific heat).
%       * A vector of numbers, equal in length to the number of finite
%         elements.  This is the non-uniform isotropic thermal
%         conductivity.
%       * A 3*3*N matrix, where N is the number of finite elements.  This
%           is the anisotropic thermal conductivity for each finite
%           element, expressed in the global frame of reference.
%           (NOT SUPPORTED)
%    temperatures is a vector of numnodes elements, giving the
%        current temperature at each node.
%    transportfield contains a vector for every finite element, giving the
%        direction and rate of flow of the substance in that element.  If
%        this is empty, there is no transport.
%    dt is the time interval: the result is the vector of new
%        temperatures after a time dt has elapsed.
%    fixednodes is a list of those elements of the temperature vector whose
%        values are assumed to be fixed.

% Preliminary check to see if there is anything to do.
% If there are no temperatures then there is nothing to do.
% There can be no change if all nodes are fixed (but this test has already
% been done in diffusegrowth().
% There can be no change from production if production is everywhere zero.
% There can be no change from absorption if absorption is everywhere zero.
% There can be no change from diffusion if either conductivity is zero or
% temperatures is uniform.
% If there is no change from any of these then there is nothing to do.

    SPLAT = false;
    NOSPLAT = true;
    
    verbose = true;
    sb = findStopButton( m );
    STEADYSTATE = all(isinf(conductivity));
    numnodes = size(nodecoords,1);
    numFEs = size(cellvertexes,1);
    vxsPerFE = size(cellvertexes,2);
    usecgs = true;  % 1: Use the conjugate gradient solver. 0: Use matrix inversion.
    SPARSESIZE = 20000;  % Should somehow estimate from result of memory().
    usesparse = numnodes >= SPARSESIZE;
    if SPLAT
        alldof = zeros( vxsPerFE, numFEs );
        Cparts = zeros( vxsPerFE, vxsPerFE, m.globalProps.solverprecision );
        Hparts = zeros( vxsPerFE, vxsPerFE, m.globalProps.solverprecision );
        Aparts = zeros( vxsPerFE, 1, m.globalProps.solverprecision );
        if STEADYSTATE
            Adparts = zeros( vxsPerFE, 1, m.globalProps.solverprecision );
        end
    end
    if NOSPLAT
        if ~usesparse
            try
                C = zeros(numnodes,numnodes,m.globalProps.solverprecision);
                H = zeros(numnodes,numnodes,m.globalProps.solverprecision);
                A = zeros(numnodes,1,m.globalProps.solverprecision);
                if STEADYSTATE
                    % Ap = zeros(numnodes,1,m.globalProps.solverprecision);
                    Ad = zeros(numnodes,1,m.globalProps.solverprecision);
                end
            catch
                fprintf( 1, 'Cannot allocate full %dx%d matrices for diffusion, trying sparse.\n', numnodes, numnodes );
                usesparse = true;
            end
        else
            fprintf( 1, 'Not attempting to allocate full %dx%d matrices for diffusion, trying sparse.\n', numnodes, numnodes );
        end
        if usesparse
            fesPerVertex = 20; % Very rough estimate.
            estimatedSpace = numnodes*getNumVxsPerFE( m )*fesPerVertex;
            C = spalloc( numnodes, numnodes, estimatedSpace );
            H = spalloc( numnodes, numnodes, estimatedSpace );
            A = spalloc(numnodes,1,numnodes);
            if STEADYSTATE
                % Ap = spalloc(numnodes,1,numnodes);
                Ad = spalloc(numnodes,1,numnodes);
            end
        end
    end
    
    totalproduction = production*dt - temperatures.*(1 - exp( -absorption*dt ));
    
    
    numvxs = size(fe.canonicalVertexes,1);
    numquadpts = size(fe.quadraturePoints,1);
    starttime = tic;
    reportInterval = 10000;
    if numel(conductivity)==1
        feconductivity = conductivity + zeros(numFEs,1);
    elseif numel(conductivity)==getNumberOfFEs(m)
        feconductivity = conductivity;
    else
        feconductivity = perVertextoperFE( m, conductivity, 'min' );
    end
    for fei=1:numFEs
        % Need to make new computations of:
        %   cellC: twice the integrals of N(i)*N(j) over the cell
        %   thiscellH2: integral over the cell of the dot products of the
        %       gradients of any two shape functions. 
        %   In general the gradients of the shape functions in Euclidean
        %   coordinates are not polynomials, therefore we cannot use exact
        %   integration, nor the polynomial gaussquadrature function.  We
        %   must loop over the quadrature points here.
        
        % So for each quadrature point, we must do this:
        % 1.  Calculate Igrad at that point, giving a 3x3 matrix of
        % numbers.
        % 2.  Calculate Nisograd at that point, giving a 3-element vector.
        % 3.  Combine 1 and 2 to get the shape gradients in the Euclidean
        % frame.
        
        vxcoords = nodecoords( cellvertexes(fei,:), : );
        
        [~,gradNeuc,weightedJacobians] = fe.interpolationData( vxcoords );
        
        NN = reshape( fe.shapequadproducts * weightedJacobians, numvxs, numvxs );
        gradNeucRep = repmat( permute( gradNeuc, [1,2,4,3] ), [1,1,numvxs,1] );
        gradNgradN = permute( sum( gradNeucRep .* permute( gradNeucRep, [3,2,1,4] ), 2 ), [1,3,4,2] );

        intgradNgradN = reshape( reshape( gradNgradN, [], numquadpts ) * weightedJacobians, ...
                                 numvxs, numvxs );
        if STEADYSTATE
            thiscellH2 = intgradNgradN;
        else
            thiscellH2 = intgradNgradN * feconductivity(fei);
        end
        cellvolume = sum(weightedJacobians);
        
        renumber = cellvertexes(fei,:);
        
        if SPLAT
            alldof(:,fei) = renumber(:);
            Cparts(:,:,fei) = NN;
            Hparts(:,:,fei) = thiscellH2;
            Aparts(:,fei) = (cellvolume/numvxs) * totalproduction(renumber);
            if STEADYSTATE
                Adparts(:,fei) = - (cellvolume/numvxs) * temperatures(renumber).*absorption(renumber);
            end
        end
        
        if NOSPLAT
            C(renumber,renumber) = C(renumber,renumber) + NN;
            H(renumber,renumber) = H(renumber,renumber) + thiscellH2;

    %         A(renumber) = A(renumber) + (cellvolume/numvxs) * ( ...
    %                 production(renumber)*dt ...
    %                 - temperatures(renumber).*(1 - exp( -absorption*dt )) ...
    %             );
            A(renumber) = A(renumber) + (cellvolume/numvxs) * totalproduction(renumber);
            if STEADYSTATE
                % Ap(renumber) = Ap(renumber) + (cellvolume/numvxs) * production(renumber);
                Ad(renumber) = Ad(renumber) - (cellvolume/numvxs) * temperatures(renumber).*absorption(renumber);
            end
        end

        % The expression (cellvolume/numvxs) in the above is the
        % portion of the volume of each finite element that is attributed
        % to each of its vertexes.
        % Precisely, it is the integral of the shape function for each
        % vertex over the volume of the element.  For the first-order
        % simplexes, by linearity this is the area or volume divided by the
        % number of vertexes.  Since we currently calculate diffusion over
        % a first-order triangular mesh for foliate meshes and a
        % first-order tetrahedral mesh for volumetric meshes, the formula
        % is correct.
        % I am not sure if the formula is correct for other types of FE.
        
        if mod(fei,reportInterval)==0
            fprintf( 1, 'Building matrix, processed %d of %d elements.\n', fei, numFEs );
            if userinterrupt( sb )
                fprintf( 1, 'Simulation interrupted by user at step %d.\n', ...
                    m.globalDynamicProps.currentIter );
                return;
            end
        end
    end
    if SPLAT
        alldof1 = reshape( repmat( alldof, vxsPerFE, 1 ), [], 1 );
        alldof2 = reshape( repmat( alldof(:)', vxsPerFE, 1 ), [], 1 );
        if usesparse
            C1 = sparse( alldof1, alldof2, Cparts(:), numnodes, numnodes );
            H1 = sparse( alldof1, alldof2, Hparts(:), numnodes, numnodes );
            A1 = sparse( alldof(:), 1, Aparts(:), numnodes, 1 );
            if STEADYSTATE
                Ad1 = sparse( alldof(:), 1, Adparts(:), numnodes, 1 );
            end
        else
            C1 = accumarray( [alldof1, alldof2], Cparts(:), [numnodes, numnodes] );
            H1 = accumarray( [alldof1, alldof2], Hparts(:), [numnodes, numnodes] );
            A1 = accumarray( alldof(:), Aparts(:), [numnodes, 1] );
            if STEADYSTATE
                Ad = accumarray( alldof(:), Adparts(:), [numnodes, 1] );
            end
        end
    end
    if SPLAT
        if NOSPLAT
            Cerr = max(abs(C(:)-C1(:)))
            Herr = max(abs(H(:)-H1(:)))
            Aerr = max(abs(A-A1))
            if STEADYSTATE
                Aderr = max(abs(Ad-Ad1))
            end
        else
            C = C1;
            H = H1;
            A = A1;
            if STEADYSTATE
                Ad = Ad1;
            end
        end
    end
    
    elapsedtime = toc(starttime);
    fprintf( 1, '%s: New method constructs matrices in %f seconds.\n', mfilename(), elapsedtime );
    
    % The equation we must now solve is this:
    % (C+H*dt)*newT = C*T + f*dt
    % where f is the external flow into or out of each vertex.
    % (See 7.32 of Zienkiewicz vol.1 (6th ed.).)
    % The external flow consists of two parts: a rate of production,
    % independent of the temperature, and a rate of decay, proportional to
    % the temperature.
    % Flow is also implied by constraints that require the temperature at
    % certain nodes to remain fixed: exactly the right amount of heat
    % energy must be added to or removed from those vertexes to maintain
    % their fixed temperatures.
    % For notational simplicity, suppose that the nodes with fixed
    % temperatures are some initial segment of the vector (i.e. fixednodes
    % = 1:n for some n).  We can split up the vectors and matrices
    % accordingly: t = (t1 t2) where t1 is the fixed temperatures (hence
    % already known) and t2 the unfixed temperatures (the new values of
    % which must be computed).  The above equation becomes two equations:
    %
    % D11*t1 + D12*newt2 = C11*t1 + C12*t2 + f1*dt
    % D21*t1 + D22*newt2 = C21*t1 + C22*t2 + f2*dt
    %
    % We ignore the first, since we are not interested in the value of f1.
    % The second can be rearranged thus:
    %
    % D22*newt2 = C21*t1 + C22*t2 - D21*t1 + f2*dt
    %           = C22*t2 - H21*t1*dt + f2*dt
    %
    % and therefore
    %
    % newt2 = inv(D22)*(C22*t2 - H21*t1*dt + f2*dt)
    %
    % f2 is assumed to be zero.
    %
    % If the substance T decays (except at the places where it is held
    % fixed) then t2 in the above should be replaced by t2.*exp(-a*dt)
    % for the absorption constant a.
    remainingTemps = eliminateVals( numnodes, fixednodes ); 
    numVarying = length(remainingTemps);
    H21 = H(remainingTemps,fixednodes);
    H = H(remainingTemps,remainingTemps);  % H22
    % D = C + H*dt;
    % D22 = D(remainingTemps,remainingTemps);
    C = C(remainingTemps,remainingTemps);  % C22
    D = C + H*dt;  % D22
    A = A(remainingTemps,:);  % A2
    if STEADYSTATE
        % Ap = Ap(remainingTemps,:);  % Not used.  This has to do with production, which is not applicable to steady state diffusion.
        Ad = Ad(remainingTemps,:);
    end
    t1 = temperatures(fixednodes,:);
    t2 = temperatures(remainingTemps,:);
    % F = C22*t2 - H21*(t1*dt) + A2;
    % Solve D22*newt2 = F for newt2.
    F = -(H*t2 + H21*t1)*dt + A;
    % Solve D22*dt2 = F for dt2 = newt2-t2.
%     
%     dd = clearDiffusionFEData();
%     dd = getDiffusionFEData( dd, fe, nodecoords, cellvertexes, true, false, fixednodes );
%     errH21 = max(abs(dd.H21c(:)*conductivity-H21(:)))
%     errH22 = max(abs(dd.H22c(:)*conductivity-H22(:)))
%     errC22 = max(abs(dd.C22(:)-C22(:)))
    
    if usecgs
        cgmaxiter = size(D,1)*40;
      % initestimate = t2 + rand(size(t2))*(0.0001*max(abs(t2(:))));
        initestimate = t2 + rand(size(t2))*(perturbation*max(abs(t2(:))));
        starttic = tic;
        if STEADYSTATE
            for i=1:numVarying
                H(i,i) = H(i,i) - Ad(i);
            end
            [t2,cgflag,cgrelres,cgiter] = mycgs( sparse(H), ...
                                                 - H21*t1, ...
                                                 tolerance, ...
                                                 tolerancemethod, ...
                                                 cgmaxiter, ...
                                                 maxtime, ...
                                                 initestimate, ...
                                                 verbose, ...
                                                 @teststopbutton, ...
                                                 m );
        else
            [dt2,cgflag,cgrelres,cgiter] = mycgs( sparse(D), ...
                                                 F, ...
                                                 tolerance, ...
                                                 tolerancemethod, ...
                                                 cgmaxiter, ...
                                                 maxtime, ...
                                                 initestimate, ...
                                                 verbose, ...
                                                 @teststopbutton, ...
                                                 m );
            t2 = t2 + dt2;
        end
        fprintf( 1, 'Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
            toc(starttic) );
        if cgflag ~= 0
            if cgflag==20
                fprintf( 1, 'CGS failed to converge to tolerance %g after %d seconds, %d of %d iterations.\n', ...
                    cgrelres, round(maxtime), cgiter, cgmaxiter );
            else
                cgsmsg( cgflag,cgrelres,cgiter,cgmaxiter );
            end
        end
        OTHERWAY = false;
        if OTHERWAY
            F3 = -(H21*t1) + (C-H*dt)*t2;
            starttic = tic;
            [t3,cgflag3,cgrelres3,cgiter3] = mycgs( sparse(C), ...
                                                    F3, ...
                                                    tolerance, ...
                                                    tolerancemethod, ...
                                                    cgmaxiter, ...
                                                    maxtime, ...
                                                    initestimate, ...
                                                    verbose, ...
                                                    @teststopbutton, ...
                                                    m );
            fprintf( 1, 'Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
                toc(starttic) );
          % t2 = (t2+t3)/2;
          % t2 = t3
        end
    else
        starttic = tic;
        if STEADYSTATE
            t2 = H\(-H21*t1);
        else
            t2 = temperatures(remainingTemps) + D\F;
        end
        fprintf( 1, 'Computation time for diffusion (matrix inversion,full,double) is %.6f seconds.\n', ...
            toc(starttic) );
    end
    temperatures(remainingTemps) = t2;
end
