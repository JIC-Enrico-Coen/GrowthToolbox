function temperatures = tempdiff( nodecoords, cellvertexes, conductivity, ...
    absorption, production, temperatures, transportfield, dt, fixednodes, ...
    cellareas, cellnormals, tolerance, tolerancemethod, maxtime, m )
%temperatures = tempdiff( nodecoords, cellvertexes, conductivity, ...
%        absorption, production, temperatures, transportfield, dt, ...
%        fixednodes, cellareas )
%    Perform a finite-element computation of thermal diffusion.
%    nodecoords is a numnodes*3 array of coordinates.
%    cellvertexes is a numcells*3 array of node indexes: each row
%        lists the node indexes of the three vertices of the cell.
%    conductivity is one of the following:
%       * A single number.  This is the uniform isotropic thermal
%         conductivity (divided by the specific heat).
%       * A vector of numbers, equal in length to the number of finite
%         elements.  This is the non-uniform isotropic thermal
%         conductivity.
%       * A 3*3*N matrix, where N is the number of finite elements.  This
%           is the anisotropic thermal conductivity for each finite
%           element, expressed in the global frame of reference.
%    temperatures is a vector of numnodes elements, giving the
%        current temperature at each node.
%    transportfield contains a vector for every finite element, giving the
%        direction and rate of flow of the substance in that element.  If
%        this is empty, there is no transport.
%    dt is the time interval: the result is the vector of new
%        temperatures after a time dt has elapsed.
%    fixednodes is a list of those elements of the temperature vector whose
%        values are assumed to be fixed.

    global gUSENEWFES_DIFFUSE FE_T3
    
    verbose = true;
    fprintf( 2, '%s %s: beginning\n', datestring(), mfilename() );

    STEADYSTATE = all(isinf(conductivity));
    numnodes = size(nodecoords,1);
    numcells = size(cellvertexes,1);
    usecgs = true;  % 1: Use the conjugate gradient solver. 0: Use matrix inversion.
    usesparse = m.globalProps.alwayssparse;
    uniformAbsorption = numel(absorption)==1;
    realtype = 'double';
    if usesparse
        fprintf( 2, '%s %s: allocating sparse %s CC for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        CC = sparse(zeros(numnodes,numnodes,realtype));
        fprintf( 2, '%s %s: allocating sparse %s HH for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        HH = sparse(zeros(numnodes,numnodes,realtype));
        fprintf( 2, '%s %s: allocating sparse %s AA for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        AA = sparse(zeros(numnodes,1,realtype));
%         if STEADYSTATE
%             Ap = sparse(zeros(numnodes,1));
%             Ad = sparse(zeros(numnodes,1));
%         end
    else
        fprintf( 2, '%s %s: assigning %s CC for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        CC = zeros(numnodes,numnodes,realtype);
        fprintf( 2, '%s %s: assigned %s CC for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        
        fprintf( 2, '%s %s: assigning %s HH for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        HH = zeros(numnodes,numnodes,realtype);
        fprintf( 2, '%s %s: assigned %s HH for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        
        fprintf( 2, '%s %s: allocating %s AA for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
        AA = zeros(numnodes,1,realtype);
        fprintf( 2, '%s %s: allocated %s AA for %d nodes.\n', datestring(), mfilename(), realtype, numnodes );
%         if STEADYSTATE
%             Ap = zeros(numnodes,1);
%             Ad = zeros(numnodes,1);
%         end
    end
    fprintf( 2, '%s %s: allocation of C, H, A succeeded.\n', datestring(), mfilename() );
    
    numvxs = 3;
    % The elements of cellC are twice the integrals of N(i)*N(j) over a
    % triangular cell, where N(1), N(2), and N(3) are its shape functions.
    % This is the value for the canonical triangle whose vertexes are at
    % (0,0), (1,0), and (0,1).  For any other triangle, it must be
    % multiplied by the triangle's area.  It is independent of the
    % triangle's shape.
    cellC = [2,1,1; 1,2,1; 1,1,2]/12;
    DO_TRANSPORT = ~isempty( transportfield );
    
    DIFF_UNIFORM_ISO = 1;
    DIFF_NONUNIFORM_ISO = 2;
    DIFF_ANISO = 3;
    DIFF_INFINITE = 4;
    if STEADYSTATE
        DIFFUSION_TYPE = DIFF_INFINITE;
        conductivity = 1;
    elseif numel(conductivity)==1
        DIFFUSION_TYPE = DIFF_UNIFORM_ISO;
    elseif numel(conductivity)==numcells
        DIFFUSION_TYPE = DIFF_NONUNIFORM_ISO;
    else
        DIFFUSION_TYPE = DIFF_ANISO;
    end

    for i=1:numcells
        % Here we calculate the matrix H, whose elements are the dot
        % products of the gradients of the shape functions, being
        % integrated over the triangular cell, and multiplied by the
        % conductivity.
        %
        % The gradients of the shape functions are constant over the
        % triangle, therefore the integration is equivalent to multiplying
        % by the area of the triangle.
        %
        % The gradients are parallel to the altitudes of the triangle,
        % directed from the base towards the vertex, and of size
        % inversely proportional to the length of the altitude.
        v1 = nodecoords( cellvertexes(i,1), : );
        v2 = nodecoords( cellvertexes(i,2), : );
        v3 = nodecoords( cellvertexes(i,3), : );
        v23 = v3 - v2;  v32 = -v23;
        v31 = v1 - v3;  v13 = -v31;
        v12 = v2 - v1;  v21 = -v12;

      % cellareavec2 = crossproc2(v21,v31); % Length equal to twice area of cell.
      % cellareavecsq4 = dot(cellareavec2,cellareavec2);
      % cellarea = sqrt(cellareavecsq4)/2;
        cellarea = cellareas(i);
        cellareavecsq4 = 4*cellarea*cellarea;
        sides = [v3;v1;v2] - [v2;v3;v1];
%             dotprods = sides*sides';
        bdiag = sum(sides.^2,2);
        boffdiag = sum( sides([3 1 2],:) .* sides([2 3 1],:), 2 );
        % The next three lines compute the squared size of each
        % shape function gradient.  The size of the gradient is 1 over
        % the corresponding altitude of the triangular cell.  The
        % altitude is twice the area of the cell divided by the
        % opposite side.
        b11 = sum(v23.*v23)/cellareavecsq4; % dot(v23,v23)/cellareavecsq4;
        b22 = sum(v31.*v31)/cellareavecsq4; % dot(v31,v31)/cellareavecsq4;
        b33 = sum(v12.*v12)/cellareavecsq4; % dot(v12,v12)/cellareavecsq4;
        % The negative signs in the next three lines are due to the
        % fact that the angle between altitudes is the complement of
        % the angle between the corresponding sides of the triangle.
        % Therefore the dot product of the altitudes has sign opposite
        % to that of the sides.
        b23 = -sum(v21.*v31)/cellareavecsq4; % -dot(v21,v31)/cellareavecsq4;
        b13 = -sum(v32.*v12)/cellareavecsq4; % -dot(v32,v12)/cellareavecsq4;
        b12 = -sum(v13.*v23)/cellareavecsq4; % -dot(v13,v23)/cellareavecsq4;


        % thiscellH2 is the array of the integral over the cell of the
        % dot products of the gradients of any two shape functions.
        % Since for a triangular cell the gradients are constant over
        % the cell, this is equivalent to computing the dot products at
        % any single point and multiplying by the cell area.
        if DIFFUSION_TYPE==DIFF_ANISO
            % Calculate the altitude vectors
            b1 = cross(cellnormals(i,:),v23)/(cellarea*2);
            b2 = cross(cellnormals(i,:),v31)/(cellarea*2);
            b3 = cross(cellnormals(i,:),v12)/(cellarea*2);
            % DiffTensor = diag([0.2,0.05,0]);
            thiscellH2 = [ b1; b2; b3 ] * conductivity(:,:,i) * [b1', b2', b3'] ...
                         * cellarea;
        else
            if (DIFFUSION_TYPE==DIFF_UNIFORM_ISO) || (DIFFUSION_TYPE==DIFF_INFINITE)
                c = conductivity;
            else
                c = conductivity(i);
            end
%           thiscellH2a = dotprods * (conductivity * cellarea);
            thiscellH2 = [ [ b11 b12 b13 ]; [ b12 b22 b23 ]; [ b13 b23 b33 ] ] ...
                         * (c * cellarea);
        end

        % The following is experimental code under development that in its
        % current state should not be executed by end users.
        if DO_TRANSPORT
            % The transport equation is
            % 
            %     du/dt = -grad(uv)
            % 
            % where u is the concentration field and v the velocity field.
            % This expands to:
            % 
            %     du/dt = -grad(u).v - u grad(v)
            % 
            % Transport is only partly implemented.  There is no
            % provision for specifying the transport field; for testing
            % purposes we hard-wire a particular field here.
            %
            % The transport term is
            % the integral of N_a mu . grad N_b over the cell for each a
            % and b.  mu is the velocity vector.  Note that N_a is not
            % constant over the cell, so we must perform the integration.
            % mu might or might not be constant over the cell.  If it is a
            % gradient it will be constant, but it might derive from a
            % vector value at each vertex, in which case it will vary.
            % We assume that mu is provided as a vector per vertex.  This
            % implies that mu . grad N_b is the linear interpolant of its
            % values at the three vertexes.  We therefore have to calculate
            % the integral over the cell of the product of two linear
            % functions, one of them being a shape function and the other
            % given by its value at each vertex.
            % Let k be a scalar determined by linear interpolation of its
            % values at the vertexes: k1, k2, k3.  Then I find that the
            % integral of k N_a over the cell is independent of which N_a is
            % chosen: it is cellarea*(k1+k2+k3)/3.  So I just have to
            % calculate mu.(grad N_b) at each vertex and take the average.
            % Since grad N_b is constant, this means taking (average
            % mu).(grad N_b).  So it makes no difference whether mu is
            % supplied as per-vertex or per-cell: in the former case we
            % immediately average it to a per-cell value.
            %             a1a = v12 - v23*boffdiag(2)/bdiag(1)
            %             a1c = v12 - v32*(dotprods(3,1)/dotprods(1,1))
            % Boundary conditions are a problem.  There should be no
            % transport perpendicular to any edge, but we have not yet
            % worked out how to express that in FE terms.  In addition, the
            % computation is found to be unstable in some circumstances.
          % cellpos = sum( m.nodes( m.tricellvxs( i, : ), : ), 1 )/3;
          % mucellvec is an artificially imposed transport field for
          % testing purposes.
          % mucellvec = [cellpos(2), -cellpos(1), 0]; % TESTING
          % mucellvec = [sqrt(0.5), sqrt(0.5), 0]; % TESTING
          % mucellvec = [0, 0.1, 0]; % TESTING
            mucellvec = transportfield(i,:); % THE REAL THING
            BOUNDARY_CONDITION = false;
            if BOUNDARY_CONDITION && ~isempty( firstborder )
                % This is an attempt to impose a boundary condition of no
                % flow across the boundary.
                borderedges = m.edgecells(m.celledges(i,:),2)==0;
                firstborder = find( borderedges, 1 );
                bordervec = sides( firstborder, : );
                effectivemucellvec = bordervec * (dot(bordervec,sides(firstborder,:))/bdiag(firstborder));
            else
                effectivemucellvec = mucellvec;
            end
            alts = sides([3,1,2],:) - sides .* repmat( (boffdiag([2,3,1])./bdiag), 1, 3 );
            muN = ((alts * effectivemucellvec') ./ sum( alts.^2, 2 ))';
            transport = cellarea * repmat( muN, 3, 1 );
            PROPORTIONAL_TRANSPORT = false;
            if PROPORTIONAL_TRANSPORT
                transport = transport * (sum( temperatures(cellvertexes(i,:)) )/3);
            end
            thiscellH2 = thiscellH2 - transport;
        end
        renumber = cellvertexes(i,:);
        CC(renumber,renumber) = CC(renumber,renumber) + cellC*cellarea;
        HH(renumber,renumber) = HH(renumber,renumber) + thiscellH2;
        if uniformAbsorption
            abs1 = absorption;
        else
            abs1 = absorption(renumber);
        end
        AA(renumber) = AA(renumber) + (cellarea/numvxs) * ( ...
                production(renumber)*dt ...
                - temperatures(renumber).*(1 - exp( -abs1*dt )) ...
            );
%         if DIFFUSION_TYPE==DIFF_INFINITE
%             Ap(renumber) = Ap(renumber) + (cellarea/numvxs) * production(renumber);
%             Ad(renumber) = Ad(renumber) - (cellarea/numvxs) * temperatures(renumber).*absorption;
%         end
    end
    fprintf( 2, '%s %s: H matrix assembled.\n', datestring(), mfilename() );
    if gUSENEWFES_DIFFUSE
        % This code is wrong. It gives the right HH, but the wrong CC.
        newC = zeros(numnodes,numnodes);
        newH = zeros(numnodes,numnodes);
        numvxs = size(FE_T3.canonicalVertexes,1);
        numquadpts = size(FE_T3.quadraturePoints,1);
        for fei=1:numcells
            vxcoords = nodecoords( cellvertexes(fei,:), : );
            [~,gradNeuc,weightedJacobians] = FE_T3.interpolationData( vxcoords );
            NN = reshape( FE_T3.shapequadproducts * weightedJacobians, numvxs, numvxs );
            newthiscellH2 = zeros( numvxs, numvxs );
            if numel(conductivity)==1
                c = conductivity;
            else
                c = conductivity(:,:,fei);
            end
            for j=1:numquadpts
                newthiscellH2 = newthiscellH2 + ...
                    gradNeuc(:,:,j) * c * gradNeuc(:,:,j)' * weightedJacobians(j);
            end
%             gradNeucRep = repmat( permute( gradNeuc, [1,2,4,3] ), [1,1,numvxs,1] );
%             gradNgradN = permute( sum( gradNeucRep .* permute( gradNeucRep, [3,2,1,4] ), 2 ), [1,3,4,2] );
%             intgradNgradN = reshape( reshape( gradNgradN, [], numquadpts ) * weightedJacobians, ...
%                                      numvxs, numvxs );
%             newthiscellH2a = intgradNgradN; %  * conductivity(:,:,fei);
                % I think we're handling conductivity wrong.  It should
                % probably go into the middle of the gradNgradN
                % computation.

            renumber = cellvertexes(fei,:);
            newC(renumber,renumber) = newC(renumber,renumber) + NN;
            newH(renumber,renumber) = newH(renumber,renumber) + newthiscellH2;
        end
        errCC = max(abs(CC(:)-newC(:)));
        errHH = max(abs(HH(:)-newH(:)));
        xxxx = 1;
%         CC = newC;
%         HH = newH;
    end
    Hdt = HH*dt;
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
    
    DT2_METHOD = true;
    varyingnodes = eliminateVals( size(CC,1), fixednodes ); 
%     numVarying = length(remainingTemps);
    D = CC + Hdt;
    fprintf( 2, '%s %s: Selecting submatrices.\n', datestring(), mfilename() );
    D22 = D(varyingnodes,varyingnodes);
    C22 = CC(varyingnodes,varyingnodes);
    H21 = HH(varyingnodes,fixednodes);
    A2 = AA(varyingnodes);
    fprintf( 2, '%s %s: Selected submatrices.\n', datestring(), mfilename() );
%     if DIFFUSION_TYPE==DIFF_INFINITE
%         Ap2 = Ap(remainingTemps,:);
%         Ad2 = Ad(remainingTemps,:);
%     end
    t1 = temperatures(fixednodes);
    t2 = temperatures(varyingnodes);
    % Solve D22*t2 = F for t2.
    if usecgs
        cgmaxiter = size(D22,1)*40;
      % initestimate = t2 + rand(size(t2))*(0.0001*max(abs(t2(:))));
        initestimate = t2 + rand(size(t2))*(m.globalProps.perturbDiffusionEstimate*max(abs(t2(:))));
        starttic = tic;
        if DIFFUSION_TYPE==DIFF_INFINITE
            % Solve H22*t2 = F for t2.
            H22 = HH(varyingnodes,varyingnodes);
%             for i=1:numVarying
%                 H22(i,i) = H22(i,i) - Ad2(i);
%             end
            fprintf( 2, '%s %s: About to solve steady state diffusion.\n', datestring(), mfilename() );
            [t2,cgflag,cgrelres,cgiter] = mycgs( sparse(H22), ...
                                                 -H21*t1, ...
                                                 tolerance, ...
                                                 tolerancemethod, ...
                                                 cgmaxiter, ...
                                                 maxtime, ...
                                                 initestimate, ...
                                                 verbose, ...
                                                 @teststopbutton, ...
                                                 m );
        elseif DT2_METHOD
            fprintf( 2, '%s %s: About to solve transient diffusion.\n', datestring(), mfilename() );
            H22 = HH(varyingnodes,varyingnodes);
            FA = -(H22*t2 + H21*t1)*dt + A2;
            % Solve D22*dt2 = FA for dt2, the change at the varying nodes.
            [dt2,cgflag,cgrelres,cgiter] = mycgs( sparse(D22), ...
                                                 FA, ...
                                                 tolerance, ...
                                                 tolerancemethod, ...
                                                 cgmaxiter, ...
                                                 maxtime, ...
                                                 initestimate, ...
                                                 verbose, ...
                                                 @teststopbutton, ...
                                                 m );
            t2 = t2 + dt2;
        else
            FF = C22*t2 - H21*(t1*dt) + A2;
            [t2,cgflag,cgrelres,cgiter] = mycgs( sparse(D22), ...
                                                 FF, ...
                                                 tolerance, ...
                                                 tolerancemethod, ...
                                                 cgmaxiter, ...
                                                 maxtime, ...
                                                 initestimate, ...
                                                 verbose, ...
                                                 @teststopbutton, ...
                                                 m );
        end
        fprintf( 2, '%s: Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
           datestring(),  toc(starttic) );
        if cgflag ~= 0
            if cgflag==20
                fprintf( 2, '%s: CGS failed to converge to tolerance %g after %d seconds, %d of %d iterations.\n', ...
                    datestring(), cgrelres, round(maxtime), cgiter, cgmaxiter );
            else
                cgsmsg( cgflag,cgrelres,cgiter,cgmaxiter );
            end
        end
        OTHERWAY = false;
        if OTHERWAY
            H22 = HH(varyingnodes,varyingnodes);
            F3 = -(H21*t1) + (C22-H22*dt)*t2;
            starttic = tic;
            [t3,cgflag3,cgrelres3,cgiter3] = mycgs( sparse(C22), ...
                                                    F3, ...
                                                    tolerance, ...
                                                    tolerancemethod, ...
                                                    cgmaxiter, ...
                                                    maxtime, ...
                                                    initestimate, ...
                                                    verbose, ...
                                                    @teststopbutton, ...
                                                    m );
            fprintf( 2, '%s: Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
                datestring(), toc(starttic) );
          % t2 = (t2+t3)/2;
          % t2 = t3
        end
    else
        starttic = tic;
        if DIFFUSION_TYPE==DIFF_INFINITE
            t2 = H22\(-H21*t1);
        else
            FF = C22*t2 - H21*(t1*dt) + A2;
            t2 = inv(D22)*FF;
        end
        fprintf( 2, '%s: Computation time for diffusion (matrix inversion,full,double) is %.6f seconds.\n', ...
            datestring(), toc(starttic) );
    end
    EXACT_METHOD = false;
    if EXACT_METHOD
        starttic = tic;
        % Test of other methods of solving the equations.
        % Only implemented for the case where there are no fixed values.
        M = CC \ HH;
        g = CC \ f;
        POLY_APPROX = true;
        if POLY_APPROX
            Mdt = M*dt;
            MTgdt = Mdt*temperatures + g*dt;
            T1 = temperatures - MTgdt + (Mdt/2 - Mdt * Mdt/6 + Mdt * Mdt * Mdt/24)*MTgdt;
        else
            eMt = expm( -M*dt );
            if any(f)
                % Note that H may well be singular, invalidating this
                % calculation. eMt*inv(H) is still well-defined, but cannot
                % be calculated thus.
                H1f = HH \ f;
                T1 = eMt*(temperatures + H1f) - H1f;
            else
                T1 = eMt*temperatures;
            end
        end
        exact_error = T1 - t2;
        t2 = T1;
        t = toc(starttic);
        fprintf( 2, '%s: Computation time for diffusion (exact method,full,double) is %.6f seconds.\n', datestring(), t );
    end
    temperatures(varyingnodes) = t2;
    fprintf( 2, '%s %s: Completed.\n', datestring(), mfilename() );
end
