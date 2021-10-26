function temperatures = diffusionFE( nodecoords, cellvertexes, fe, conductivity, ...
    absorption, production, temperatures, dt, fixednodes, ...
    ... % cellareas
    tolerance, tolerancemethod, maxtime, perturbation, m )
%temperatures = tempdiff( nodecoords, cellvertexes, conductivity, ...
%        absorption, production, temperatures, transportfield, dt, ...
%        lengthscale, fixednodes, cellareas )
%    Perform a finite-element computation of thermal diffusion.
%    nodecoords is a numnodes*3 array of coordinates.
%    cellvertexes is a numcells*K array of node indexes: each row
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
%    temperatures is a vector of numnodes elements, giving the
%        current temperature at each node.
%    transportfield contains a vector for every finite element, giving the
%        direction and rate of flow of the substance in that element.  If
%        this is empty, there is no transport.
%    dt is the time interval: the result is the vector of new
%        temperatures after a time dt has elapsed.
%    fixednodes is a list of those elements of the temperature vector whose
%        values are assumed to be fixed.

    numnodes = size(nodecoords,1);
    numcells = size(cellvertexes,1);
    usecgs = 1;  % 1: Use the conjugate gradient solver. 0: Use matrix inversion.
    usesparse = 0;
    if usesparse
        C_OLD = sparse(zeros(numnodes,numnodes));
        H_OLD = sparse(zeros(numnodes,numnodes));
        C = sparse(zeros(numnodes,numnodes));
        H = sparse(zeros(numnodes,numnodes));
        A = sparse(zeros(numnodes,1));
    else
        C_OLD = zeros(numnodes,numnodes);
        H_OLD = zeros(numnodes,numnodes);
        C = zeros(numnodes,numnodes);
        H = zeros(numnodes,numnodes);
        A = zeros(numnodes,1);
    end
    
    % The elements of cellC are twice the integrals of N(i)*N(j) over a
    % triangular cell, where N(1), N(2), and N(3) are its shape functions.
    % This is the value for the canonical triangle whose vertexes are at
    % (0,0), (1,0), and (0,1).  For any other triangle, it must be
    % multiplied by the triangle's area.  It is independent of the
    % triangle's shape.
    cellC_OLD = [2,1,1; 1,2,1; 1,1,2]/12;
    
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

    starttime = tic;
    for fei=1:numcells
        % Here we calculate the matrix H, whose elements are the dot
        % products of the gradients of the shape functions, being
        % integrated over the finite element, and multiplied by the
        % conductivity.
        
        % thiscellH2 is the array of the integral over the cell of the
        % dot products of the gradients of any two shape functions wrt
        % Euclidean space.
        % Since for a triangular cell the gradients are constant over
        % the cell, this is equivalent to computing the dot products at
        % any single point and multiplying by the cell area.
        % The gradients are in the direction of the altitudes of the
        % triangle, which are in the direction of the dot products of the
        % cell normal with the edge vectors.  The appropriate normalising
        % factor turns out to be the square of the cell area.
        v1 = nodecoords( cellvertexes(fei,1), : );
        v2 = nodecoords( cellvertexes(fei,2), : );
        v3 = nodecoords( cellvertexes(fei,3), : );
        v23 = v3 - v2;  v32 = -v23;
        v31 = v1 - v3;  v13 = -v31;
        v12 = v2 - v1;  v21 = -v12;

      % cellareavec2 = crossproc2(v21,v31); % Length equal to twice area of cell.
      % cellareavecsq4 = dot(cellareavec2,cellareavec2);
      % cellarea = sqrt(cellareavecsq4)/2;
        if length(v12)==2
            cellarea = abs(det([v12;v13])/2);
        else
            cellarea = norm(cross(v12,v13))/2; % cellareas(fei);
        end
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
        if DIFFUSION_TYPE==DIFF_ANISO
            % Calculate the gradient vectors
            b1 = cross(cellnormals(fei,:),v23)/(cellarea*2);
            b2 = cross(cellnormals(fei,:),v31)/(cellarea*2);
            b3 = cross(cellnormals(fei,:),v12)/(cellarea*2);
            % DiffTensor = diag([0.2,0.05,0]);
            thiscellH2_OLD = [ b1; b2; b3 ] * conductivity(:,:,fei) * [b1', b2', b3'] ...
                         * cellarea;
        else
            if DIFFUSION_TYPE==DIFF_UNIFORM_ISO
                c = conductivity;
            else
                c = conductivity(fei);
            end
%           thiscellH2a = dotprods * (conductivity * cellarea);
            thiscellH2_OLD = [ [ b11 b12 b13 ]; [ b12 b22 b23 ]; [ b13 b23 b33 ] ] ...
                         * (c * cellarea);
        end
    end
    elapsedtime = toc(starttime);
    fprintf( 1, 'Old method constructs matrices in %f seconds.\n', elapsedtime );
    
    numvxs = size(fe.canonicalVertexes,1);
    numquadpts = size(fe.quadraturePoints,1);
    starttime = tic;
    for fei=1:numcells
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
        
%         CHECK_OLD_METHOD = false;
%         if CHECK_OLD_METHOD
%             [~,Igrad,~] = ShapeData( fe, vxcoords );
%             Igradvalues = zeros( [ numquadpts, size(Igrad) ] );
%             for ig1 = 1:size(Igrad,1)
%                 for ig2 = 1:size(Igrad,2)
%                     Igradvalues(:,ig1,ig2) = Igrad(ig1,ig2).fulleval(fe.quadraturePoints);
%                 end
%             end
%             Igradvalues = permute( Igradvalues, [3, 2, 1] );
%         end
        
%         Igradvalues2 = reshape( vxcoords' * fe.IgradquadVxCoeffs, size(vxcoords,2), fe.numdims, numquadpts );
        [isoGrads,~,weightedJacobians] = interpolationData( fe, vxcoords );
        
%         Ijacobians = zeros(numquadpts,1);
%         for qi=1:numquadpts
%             Ijacobians(qi) = abs(det( Igradvalues2(:,:,qi) ));
%         end
        
        gradNeuc = zeros( numvxs, size(nodecoords,2), numquadpts );
        for qi=1:numquadpts
            gradNeuc(:,:,qi) = fe.shapederivquad(:,:,qi) / isoGrads(:,:,qi);
        end
        NN = reshape( fe.shapequadproducts * weightedJacobians, numvxs, numvxs );
        gradNgradN = squeeze( dot( repmat( permute( gradNeuc, [1,2,4,3] ), [1,1,numvxs,1] ), ...
                          repmat( permute( gradNeuc, [4,2,1,3] ), [numvxs,1,1,1] ), ...
                          2 ) );
        intgradNgradN = reshape( reshape( gradNgradN, [], numquadpts ) * weightedJacobians, ...
                                 numvxs, numvxs );
        cellC = NN;
        thiscellH2 = intgradNgradN * conductivity;
%         cellCerr = max(abs( cellC(:)./(cellC_OLD(:)*cellarea) - 1 ) )
%         thiscellH2err = max(abs( thiscellH2(:) - thiscellH2_OLD(:) ) )
        
        
        
        
%         numshapefns = length( fe.shapeFunctions );
% %         cellC = zeros( numshapefns, numshapefns );
%         % thiscellH2 = zeros( numshapefns, numshapefns );
%         % Evaluate
%         for si=1:numshapefns
%             for j=1:numshapefns
% %                 cellC(fei,j) = fe.integratepoly( ...
% %                     fe.shapeFunctions(si).polymult( fe.shapeFunctions(j) ), ...
% %                     vxcoords );
%             end
%         end
        
        renumber = cellvertexes(fei,:);
%         C(renumber,renumber) = C(renumber,renumber) + cellC*cellarea;
%         C_OLD(renumber,renumber) = C_OLD(renumber,renumber) + cellC_OLD*cellarea;
%         H_OLD(renumber,renumber) = H_OLD(renumber,renumber) + thiscellH2_OLD;
        C(renumber,renumber) = C(renumber,renumber) + cellC;
        H(renumber,renumber) = H(renumber,renumber) + thiscellH2;
        
%         A(renumber) = A(renumber) + (cellarea/3) * ( ...
%                 production(renumber)*dt ...
%                 - temperatures(renumber)*(1 - exp( -absorption*dt )) ...
%             );
    end
    elapsedtime = toc(starttime);
    fprintf( 1, 'New method constructs matrices in %f seconds.\n', elapsedtime );
%     C_err = max(abs(C(:)-C_OLD(:)))
%     H_err = max(abs(H(:)-H_OLD(:)))
    Hdt = H*dt;
    
    % return;
    
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
    A2 = A(remainingTemps,:);
    t1 = temperatures(fixednodes,:);
    t2 = temperatures(remainingTemps,:);
    % F = C22*t2 - H21*(t1*dt) + A2;
    F = -Hdt*t2 - H21*(t1*dt) + A2;
    % Solve D22*t2 = F for t2.
    if usecgs
        cgmaxiter = size(D22,1)*40;
      % initestimate = t2 + rand(size(t2))*(0.0001*max(abs(t2(:))));
        initestimate = t2 + rand(size(t2))*(perturbation*max(abs(t2(:))));
        starttic = tic;
%         [t2,cgflag,cgrelres,cgiter] = mycgs( sparse(D22), ...
%                                              F, ...
%                                              tolerance, ...
%                                              tolerancemethod, ...
%                                              cgmaxiter, ...
%                                              maxtime, ...
%                                              initestimate, ...
%                                              @testcallback, ...
%                                              m );
        [dt2,cgflag,cgrelres,cgiter] = mycgs( sparse(D22), ...
                                             F, ...
                                             tolerance, ...
                                             tolerancemethod, ...
                                             cgmaxiter, ...
                                             maxtime, ...
                                             initestimate, ...
                                             @testcallback, ...
                                             m );
        t2 = temperatures + dt2;
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
                                                    @testcallback, ...
                                                    m );
            fprintf( 1, 'Computation time for diffusion (cgs,sparse,double) is %.6f seconds.\n', ...
                toc(starttic) );
          % t2 = (t2+t3)/2;
          % t2 = t3
        end
    else
        starttic = tic;
        t2 = inv(D22)*F;
        fprintf( 1, 'Computation time for diffusion (matrix inversion,full,double) is %.6f seconds.\n', ...
            toc(starttic) );
    end
    temperatures(remainingTemps) = t2;
end
