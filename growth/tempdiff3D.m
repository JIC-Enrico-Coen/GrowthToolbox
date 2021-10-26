function temperatures = tempdiff3D( nodecoords, cellvertexes, conductivity, ...
    absorption, production, temperatures, transportfield, dt, fixednodes, ...
    cellareas, cellnormals, tolerance, tolerancemethod, maxtime, m )
%temperatures = tempdiff3D( nodecoords, cellvertexes, conductivity, ...
%        absorption, production, temperatures, transportfield, dt, ...
%        fixednodes, cellareas )
%   Perform a finite-element computation of thermal diffusion on a 3D mesh.
%   nodecoords is a numnodes*3 array of vertexes.
%   cellvertexes is a numcells*6 array of node indexes.  Each row lists the
%       vertexes of one FE in a standard ordering.  The A side is [1 2 3],
%       the B side is [4 5 6], the edges from A to B are [1 4], [2 5], and
%       [3 6], and the sense is such that the outward normal from B
%       satisfies the right-hand rule.
%   

%    conductivity is one of the following:
%       * A single number.  This is the uniform isotropic thermal
%         conductivity (divided by the specific heat).
%       * A vector of numbers, equal in length to the number of finite
%         elements.  This is a non-uniform isotropic thermal conductivity.
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

    verbose = true;
    numnodes = size(nodecoords,1);
    numcells = size(cellvertexes,1);
    usecgs = 1;  % 1: Use the conjugate gradient solver. 0: Use matrix inversion.
    usesparse = 0;
    uniformAbsorption = numel(absorption)==1;
    if usesparse
        C = sparse(zeros(numnodes,numnodes));
        H = sparse(zeros(numnodes,numnodes));
        A = sparse(zeros(numnodes,1));
    else
        C = zeros(numnodes,numnodes);
        H = zeros(numnodes,numnodes);
        A = zeros(numnodes,1);
    end
    
    ss = calcSS();  % Should only be done once.
    DO_TRANSPORT = ~isempty( transportfield );
    
    DIFF_UNIFORM_ISO = 1;
    DIFF_NONUNIFORM_ISO = 2;
    DIFF_ANISO = 3;
    if numel(conductivity)==1
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
        
        vxs = nodecoords( cellvertexes(i,:), : );
        tpsx = particularData( vxs );
        % The elements of cellC are the integrals of N(i)*N(j) over a
        % pentahedral cell, where N(1)...N(6) are its shape functions.
        cellC = tpsx*ss;
        cellC = cellC( [ 1  6  5  7 12 11;
                         6  2  4 12  8 10;
                         5  4  3 11 10  9;
                         7 12 11 13 18 17;
                        12  8 10 18 14 16;
                        11 10  9 17 16 15 ] );

        
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
            if DIFFUSION_TYPE==DIFF_UNIFORM_ISO
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
        C(renumber,renumber) = C(renumber,renumber) + cellC;
        H(renumber,renumber) = H(renumber,renumber) + thiscellH2;
        if uniformAbsorption
            abs = absorption;
        else
            abs = absorption(renumber);
        end
        A(renumber) = A(renumber) + (cellarea/3) * ( ...
                production(renumber)*dt ...
                - temperatures(renumber).*(1 - exp( -abs*dt )) ...
            );
        Ap(renumber) = Ap(renumber) + (cellarea/3) * production(renumber)*dt;
        Aa(renumber) = Aa(renumber) - (cellarea/3) * temperatures(renumber).*(1 - exp( -abs*dt ));
        Acheck = Ap + Aa;
        xxxx = 1;
    end
    Hdt = H*dt;
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
    % fixed) then t2 in the above should be replaced by t2*exp(-a*dt)
    % for the absorption constant a.
    remainingTemps = eliminateVals( size(C,1), fixednodes ); 
    D = C + Hdt;
    D22 = D(remainingTemps,remainingTemps);
    C22 = C(remainingTemps,remainingTemps);
    H21 = H(remainingTemps,fixednodes);
    A2 = A(remainingTemps);
    t1 = temperatures(fixednodes);
    t2 = temperatures(remainingTemps);
    F = C22*t2 - H21*(t1*dt) + A2;
    % Solve D22*t2 = F for t2.
    if usecgs
        cgmaxiter = size(D22,1)*40;
      % initestimate = t2 + rand(size(t2))*(0.0001*max(abs(t2(:))));
        initestimate = t2 + rand(size(t2))*(m.globalProps.perturbDiffusionEstimate*max(abs(t2(:))));
        starttic = tic;
        [t2,cgflag,cgrelres,cgiter] = mycgs( sparse(D22), ...
                                             F, ...
                                             tolerance, ...
                                             tolerancemethod, ...
                                             cgmaxiter, ...
                                             maxtime, ...
                                             initestimate, ...
                                             verbose, ...
                                             @teststopbutton, ...
                                             m );
        fprintf( 1, '%s: Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
            datestring(), toc(starttic) );
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
            H22 = H(remainingTemps,remainingTemps);
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
            fprintf( 1, '%s: Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
                datestring(), toc(starttic) );
          % t2 = (t2+t3)/2;
          % t2 = t3
        end
    else
        starttic = tic;
        t2 = inv(D22)*F;
        fprintf( 1, '%s: Computation time for diffusion (matrix inversion,full,double) is %.6f seconds.\n', ...
            datestring(), toc(starttic) );
    end
    EXACT_METHOD = false;
    if EXACT_METHOD
        starttic = tic;
        % Test of other methods of solving the equations.
        % Only implemented for the case where there are no fixed values.
        M = C \ H;
        g = C \ f;
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
                H1f = H \ f;
                T1 = eMt*(temperatures + H1f) - H1f;
            else
                T1 = eMt*temperatures;
            end
        end
        exact_error = T1 - t2;
        t2 = T1;
        t = toc(starttic);
        fprintf( 1, '%s: Computation time for diffusion (exact method,full,double) is %.6f seconds.\n', datestring(), t );
    end
    temperatures(remainingTemps) = t2;
end

function ss = calcSS()
% Hard-wired data about the canonical pentahedron.
    s1  = [4 4 4 2 2 2]/72;    s1  = [ s1, s1/2, s1 ];
    sx  = [12 4 4 2 4 4]/360;  sx  = [ sx, sx/2, sx ];
    sy  = [4 12 4 4 2 4]/360;  sy  = [ sy, sy/2, sy ];
    sz  = [2 2 2 1 1 1]/72;    sz  = [ -sz, 0 0 0 0 0 0, sz];
    sxz = [6 2 2 1 2 2]/360;   sxz = [ -sxz, 0 0 0 0 0 0, sxz];
    syz = [2 6 2 2 1 2]/360;   syz = [ -syz, 0 0 0 0 0 0, syz];
    szz = [8 8 8 4 4 4]/360;   szz = [ szz, szz/4, szz ];
    ss  = [ s1; sx; sy; sz; sxz; syz; szz ];
end

function tpsx = particularData( vxs )
%   Perform that part of the calculation which depends on the particular
%   pentahedron.
%
% The result is a representation of a polynomial in three variables.
% Each row is one term.  The first three elements are the powers of x,
% y, and z, and the fourth is the coefficient.

    v1 = vxs(1,:);
    v2 = vxs(2,:);
    v3 = vxs(3,:);
    v4 = vxs(4,:);
    v5 = vxs(5,:);
    v6 = vxs(6,:);
    
    v13 = (v1-v3)/2;
    v46 = (v4-v6)/2;
    v23 = (v2-v3)/2;
    v56 = (v5-v6)/2;
    v36 = (v3-v6)/2;
    
    dx1 = v13 + v46; % (+v1-v3+v4-v6)/2;
    dxz = -v13 + v46; % (-v1+v3+v4-v6)/2;
    dy1 = v23 + v56; % (+v2-v3+v5-v6)/2;
    dyz = -v23 + v56; % (-v2+v3+v5-v6)/2;
    dz1 = -v36; % (-v3+v6)/2;
    
    % We want half the triple product of these three vectors:
    % dx1 + z*dxz
    % dy1 + z*dyz
    % dz1 + x*dzx + y*dzy
    % for any point x, y, z.
    % This is a cubic polynomial in x, y, and z with terms for
    % 1, x, y, z, xz, yz, z^2, xz^2, and yz^2.  Each coefficient is a
    % combination of triple products of the vectors dAB we have just
    % calculated.  In general, all of these coefficients can be non-zero.
    
    if true
        tp1 = det( [dx1; dy1; dz1] );
        tpx = det( [dx1; dy1; dxz] );
        tpy = det( [dx1; dy1; dyz] );
        
        tpz1 = det( [dx1; dyz; dz1] );
        tpz2 = det( [dxz; dy1; dz1] );
        tpz = tpz1+tpz2;
        
        tpxz = -det( [dxz; dyz; dx1] );
        tpyz = -det( [dxz; dyz; dy1] );
        tpzz = det( [dxz; dyz; dz1] );
        tpsx = [ tp1 tpx tpy tpz tpxz tpyz tpzz ];
    else
        % This is slower.
        v = cross(dx1,dy1)*[dz1', dxz', dyz'];
        
        tpz1 = det( [dx1; dyz; dz1] );
        tpz2 = det( [dxz; dy1; dz1] );
        tpz = tpz1+tpz2;
        
        w = cross(dxz,dyz)*[-dx1', -dy1', dz1'];
        
        tpsx = [ v tpz w ];
    end
end
