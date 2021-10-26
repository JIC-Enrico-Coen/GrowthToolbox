classdef FiniteElementType
    properties
        % The sizes of the various arrays are given symbolically in terms
        % of the following numbers:
        %   D: the dimensionality of the space.
        %   V: the number of vertexes of the FE.
        %   Q: the number of quad points of the FE.
        %   Each array consists of either numbers or polynomial structures.
        
        % This block of properties is what defines the FE type.  The remainder
        % are calculated from these and cached.  All of this is independent of
        % the actual vertex positions of any particular element.
        name = '';
        numdims = 0;
        typeparams = struct( 'numboxdims', 0, ...
                             'numsimplexdims', 0, ...
                             'elementDegree', 0, ...
                             'quadratureDegree', 0 );
        canonicalVertexes = [];  % [V D]
        canonicalVolume = 0;
        edges = [];
        faces = [];
        shapeFunctions = [];     % [1 V] polynomials.
        quadraturePoints = [];   % [Q D]
        quadratureWeights = [];  % [Q 1]
        
        
        
        % The following components are computed by PRECOMPUTE.
        % SHAPEJACOBIAN is a polynomial on X, Y, Z, and one additional
        % variable for every term in the polynomial.  To compute the
        % Jacobian for a given concrete FE with vertexes VXCOORDS, compute
        % VCOMBS, a set of linear combinations of the vertexes by
        % JACOBIANVXCOMBS*VXCOORDS, then compute a set of triple products
        % of members of VCOMBS using detspec, which specifies a triple
        % of indexes into VCOMBS for each monomial of SHAPEJACOBIAN.
        % SHAPEQUAD contains the values of all the shape functions at the
        % quadrature points.  Each shape function corresponds to a column,
        % each quadrature point to a row.
        shapeJacobian = [];  % A single polynomial.
        jacobianVxcombs = []; % [V V]
        detspec = [];  % [x D] where x is not a very meaningful number
            % This appears not to be used anywhere, as whatever it was
            % projected to be used for, it turned out to be impractically
            % inefficient.
        
        isomap = [];  % A single polynomial.
        % The isoparametric mapping, an abstract polynomial whose variables
        % are the isopar coords, and one variable for every vertex.  When a
        % concrete vertex is substituted for each of the vertex variables,
        % this gives a vector-valued polynomial in the isopar coords.
        
        isograd = []; % [1 D] polynomials.
        % The gradient of the isoparametric mapping, a list of abstract
        % polynomials, one for each isopar coord.
        % Its variables are the isopar coords, and one variable for each
        % of a set of combinations of the vertexes.  These combinations are
        % specified by jacobianVxcombs.  When this multiples the concrete
        % vertex coordinates and the resulting vectors are substituted for
        % the latter set of variables of isograd, the result is a list of
        % vector-valued polynomials.
        % isograd is indexed by the isopar coords: the i'th element is the
        % derivative with respect to the i'th isopar coord.
        
        shapequad = [];  % [V Q]
        % The value of every shape function at every quadrature point.
        % Indexed by vertex (shape function), then quad point.
        
        shapequadproducts = [];  % [V*V Q]
        % The product of the value of any two shape functions at every
        % quadrature point.  This is calculated indexed by vertex, then
        % vertex, then quadpoint, but is then reshaped to combine the first
        % two dimensions into one.  It is symmetric in those first two
        % dimensions.
        
        shapederivquad;  % [V D Q]
        % The value of the derivative of every shape function with respect
        % to every isopar coord at every quad point.
        % Indexed by shape function, then isopar coord, then quadpoint.
        % Size is V*D*Q,
        
        Igradquad;  % [D Q] polynomials
        % The value of the gradient of the isoparametric mapping at each of
        % the quadrature points, expressed as a set of polynomials, one for
        % each quadrature point, whose variables correspond to certain
        % linear combinations of the vertexes. 
        
        IgradquadVxcombCoeffs;
        % Igradquad represented more compactly as a table of numbers.
        
        IgradquadVxCoeffs;
        % Igradquad represented more compactly as a table of numbers.
    end
    
    methods (Static)
        
        function fe = MakeFEType( numboxdims, numsimplexdims, elementDegree, quadratureDegree )
            %fe = MakeFEType( numboxdims, numsimplexdims, elementDegree, quadratureDegree )
            % Make a finite element of given dimensions and complexity.
            % The first two arguments specify the type of shape:
            % Line:             1, 0
            % Quadrilateral:    2, 0
            % Box (hexahedron): 3, 0
            % Triangle:         0, 2
            % Tetrahedron:      0, 3
            % Pentahedron:      1, 2
            % ElementDegree is a positive integer specifying the number of
            %   subdivisions of each edge.
            % QuadratureDegree is a positive integer specifying the degree of
            %   Gaussian quadrature.
            % For elementDegree and quadratureDegree, only a limited number
            % of different values are supported.
            % Instead of these four values a single short name can be
            % given:
            %   L2: linear line element, linear quadrature
            %   Q4: linear quadrilateral, quadratic quadrature
            %   H8: linear box, quadratic quadrature
            %   H8Q: quadratic box, cubic quadrature
            %   T3: linear triangle, linear quadrature
            %   T3A: linear triangle, hybrid quadrature
            %   T3Q: quadratic triangle, quartic quadrature
            %   T4: linear tetrahedron, quadratic quadrature
            %   T4Q: linear tetrahedron, cubic quadrature
            %   T4Q2: quadratic tetrahedron, cubic quadrature
            %   P6: linear pentahedron, hybrid quadrature
            %   The short name can also be a string of the form Ba-Sb-Dc-Gd,
            %   where a, b, c, and d are the four (integer) arguments.
            %   This is equivalent to calling MakeFEType(a,b,c,d).
            %   When numsimplexdims==2, quadratureDegree can be 2.5.  This
            %   chooses an alternate set of quadratic quadrature points for
            %   the two-dimensional simplex.
            
            if isa(numboxdims,'FiniteElementType')
                fe = numboxdims;
                return;
            end
            
            if ischar( numboxdims )
                switch numboxdims
                    case 'L2'
                        fe = FiniteElementType.MakeFEType( 1, 0, 1, 1 );
                    case 'Q4'
                        fe = FiniteElementType.MakeFEType( 2, 0, 1, 2 );
                    case 'H8'
                        fe = FiniteElementType.MakeFEType( 3, 0, 1, 2 );
                    case 'H8Q'
                        fe = FiniteElementType.MakeFEType( 3, 0, 2, 3 );
                    case 'T3'
                        fe = FiniteElementType.MakeFEType( 0, 2, 1, 1 );
                    case 'T3A'
                        fe = FiniteElementType.MakeFEType( 0, 2, 1, 2.5 );
                    case 'T3Q'
                        fe = FiniteElementType.MakeFEType( 0, 2, 2, 4 );
                    case 'T4'
                        fe = FiniteElementType.MakeFEType( 0, 3, 1, 2 );
                    case 'T4Q'
                        fe = FiniteElementType.MakeFEType( 0, 3, 1, 3 );
                    case 'T4Q2'
                        fe = FiniteElementType.MakeFEType( 0, 3, 2, 3 );
                    case 'P6'
                        fe = FiniteElementType.MakeFEType( 1, 2, 1, 2.5 );
                        % 2.5 is a special value that invokes the old quad points.
                    otherwise
                        [b,s,d,g] = parseSpec( numboxdims );
                        if (d==0)
                            error( 'Finite element type %s not recognised.', numboxdims );
                        else
                            fe = FiniteElementType.MakeFEType( b, s, d, g );
                        end
                end
                return;
            end
            
            if isstruct( numboxdims )
                s = numboxdims;
                numboxdims = s.numboxdims;
                numsimplexdims = s.numsimplexdims;
                elementDegree = s.elementDegree;
                quadratureDegree = s.quadratureDegree;
            end

            fe = FiniteElementType();
            if numsimplexdims==1
                numboxdims = numboxdims+1;
                numsimplexdims = 0;
            end
            if numboxdims==0
                typename = sprintf( 'S%d', numsimplexdims );
            elseif numsimplexdims==0
                typename = sprintf( 'B%d', numboxdims );
            else
                typename = sprintf( 'B%d-S%d', numboxdims, numsimplexdims );
            end
            typename = [ typename, sprintf( '-D%d-G%g', elementDegree, quadratureDegree ) ];
            fe.name = typename;
            fe.numdims = numboxdims + numsimplexdims;
            fe.typeparams = struct( 'numboxdims', numboxdims, ...
                                    'numsimplexdims', numsimplexdims, ...
                                    'elementDegree', elementDegree, ...
                                    'quadratureDegree', quadratureDegree );
            vxs = [];
            e = zeros(0,2);
            quadpts = [];
            w = 1;
            numdegrees = numboxdims;
            if quadratureDegree > 0
                numdegrees = numdegrees+1;
            end
            if numel(elementDegree)==1
                elementDegree = elementDegree*ones(1,numdegrees);
            elseif numel(elementDegree) ~= numdegrees
                error( 'Wrong number of element degrees specified: %d required, %d found.', ...
                    numdegrees, numel(elementDegree) );
            end
            vxperedge = elementDegree+1;
            if numel(quadratureDegree)==1
                quadratureDegree = quadratureDegree*ones(1,numdegrees);
            elseif numel(quadratureDegree) ~= numdegrees
                error( 'Wrong number of quadrature degrees specified: %d required, %d found.', ...
                    numdegrees, numel(quadratureDegree) );
            end
            allshapefuns = [];
            if numboxdims > 0
                for i=1:numboxdims
                    xs = linspace(-1,1,elementDegree(i)+1)';
                    vxs = vertexProduct( vxs, xs );
                    [q1,w1] = basicQuadraturePoints( 0, quadratureDegree(i) );
                    quadpts = vertexProduct( quadpts, q1 );
                    w = w*w1';  w = w(:);
                    edges1 = [ (1:elementDegree(i))', (2:vxperedge(i))' ];
                    e = edgeProduct( edges1, e );
                    for j=vxperedge(i):-1:1
                        shapefn = polynomial.lagrangePoly( vxperedge(i)-1, j-1, linspace( -1, 1, vxperedge(i) ), char('X'-1+i+numsimplexdims) );
                        if isempty( allshapefuns )
                            newallshapefuns(j) = shapefn;
                        else
                            for k=length(allshapefuns):-1:1
                                newallshapefuns(k + (j-1)*length(allshapefuns)) = ...
                                    allshapefuns(k).polymult( shapefn );
                            end
                        end
                    end
                    allshapefuns = newallshapefuns;
                end
            end
            if numsimplexdims > 0
                [vsimplex,edges1] = generateSimplex( numsimplexdims, elementDegree(end) );
                vxs = vertexProduct( vsimplex/elementDegree(end), vxs );
                [q1,w1] = basicQuadraturePoints( numsimplexdims, quadratureDegree(end) );
                quadpts = vertexProduct( q1, quadpts );
                w = w1*w';  w = w(:);
                e = edgeProduct( edges1, e );
                lpts = linspace( 0, 1, vxperedge(end) );
                for j=size(vsimplex,1):-1:1
                    I = vsimplex(j,1);
                    p = polynomial.lagrangePoly( I, I, lpts, 'X' );
                    vars{1} = 'X';
                    for k=2:size(vsimplex,2)
                        v = char('X'-1+k);
                        J = vsimplex(j,k);
                        q = polynomial.lagrangePoly( J, J, lpts, v );
                        p = p.polymult( q );
                        vars{k} = v;
                    end
                    r = polynomial( [ zeros(1,numsimplexdims); eye(numsimplexdims) ], ...
                                    [ 1; -ones(numsimplexdims,1) ], ...
                                    vars );
                    K = elementDegree(end) - sum(vsimplex(j,:));
                    q = polynomial.lagrangePoly( K, K, lpts, 'X' );
                    qr = q.substitute( 'X', r );
                    p = p.polymult( qr );
                    simplexshapefns(j) = p;
                end
                
                if isempty(allshapefuns)
                    allshapefuns = simplexshapefns;
                else
                    for i=length(allshapefuns):-1:1
                        for j=length(simplexshapefns):-1:1
                            newallshapefuns(j,i) = simplexshapefns(j).polymult(allshapefuns(i));
                        end
                    end
                    allshapefuns = reshape( newallshapefuns, 1, [] );
                end
            end
            fe.canonicalVertexes = vxs;
            fe.canonicalVolume = 2^numboxdims;
            if numsimplexdims > 1
                fe.canonicalVolume = fe.canonicalVolume / numsimplexdims;
            end
            fe.edges = e';
            fe.quadraturePoints = quadpts;
            fe.quadratureWeights = w;
            fe.shapeFunctions = allshapefuns;
            switch fe.numdims
                case 2
                    switch numboxdims
                        case 0
                            fe.faces = [ 1 2 3 ]';
                        otherwise
                            fe.faces = [ 1 2 4 3 ]';
                    end
                case 3
                    switch numboxdims
                        case 0
                            % Simplex
                            switch elementDegree(1) % Is more complicated if degree is different in different directions.
                                case 1
                                    % Face vertexes are listed in the order
                                    % that makes every face read
                                    % anticlockwise when viewed from
                                    % outside in a positive-sense
                                    % tetrahedron, and every face clockwise
                                    % for a negative-sense tetrahedron.
                                    fe.faces = [ 1 2 4;
                                                 1 3 2;
                                                 1 4 3;
                                                 2 3 4 ]';
                                case 2
                                    % I'm not quite sure this is correct.
                                    % [RK 2016 Oct]
                                    fe.faces = [ 1 2 3 8 10 7;
                                                 1 4 6 5 3 2;
                                                 1 7 10 9 6 4;
                                                 3 5 6 9 10 8 ]';
                                otherwise
                                    error('3D simplex element must have quadrature degree 2 or 3, %g found.', quadratureDegree );
                            end
                        case 1
                            % Triangular prism
                            % elementDegree assumed to be 1 -- higher order
                            % prisms not implemented.
                            fe.faces = [ 1 3 2 0;
                                         4 5 6 0;
                                         1 2 5 4;
                                         2 3 6 5;
                                         3 1 4 6 ]';
                        otherwise
                            % Box
                            switch elementDegree(1) % Is more complicated if degree is different in different directions.
                                case 1
                                    fe.faces = [ 1 3 4 2;
                                                 5 6 8 7;
                                                 1 2 6 5;
                                                 2 4 8 6;
                                                 3 7 8 4;
                                                 3 1 5 7 ]';
                                case 2
%                                     fe.faces = [ 1 7 9 3;
%                                                  19 21 27 25;
%                                                  1 3 21 19;
%                                                  3 9 27 21;
%                                                  7 25 27 9;
%                                                  7 1 19 25 ]';
                                    fe.faces = [ 1 4 7 8 9 6 3 2 ;
                                                 19 20 21 24 27 26 25 22;
                                                 1 2 3 12 21 20 19 10;
                                                 3 6 9 18 27 24 21 12;
                                                 7 16 25 26 27 18 9 8;
                                                 7 4 1 10 19 22 25 16 ]';
                                otherwise
                                    error('3D box element must have quadrature degree 2 or 3, %g found.', quadratureDegree );
                            end
                    end
            end
            
            fe = fe.Precompute();
        end
        
    end
        
    methods
        function s = GetSpecification( fe )
            [b,s,d,g] = parseSpec( fe.name );
        	s = struct( 'numboxdims', b, ...
                        'numsimplexdims', s, ...
                        'elementDegree', d, ...
                        'quadratureDegree', g );
        end
        
        function fe = Precompute( fe )
            numvxs = size( fe.canonicalVertexes, 1 );
            numquadpts = size(fe.quadraturePoints,1);
            
            isovars = fe.shapeFunctions(1).variables;
            numisovars = length(isovars);
            newvars = genvars( 'V', length(fe.shapeFunctions) );
            IVV = polynomial.zero();
            for i=1:length(fe.shapeFunctions)
                fesfi = fe.shapeFunctions(i);
                monom = polynomial( 1, 1, newvars{i} );
                IVV1 = fesfi.polymult( monom );
                IVV = IVV.sum( IVV1 );
            end
            % IVV is a formal polynomial that multiplies each shape
            % function by a new variable and adds together the results.
            % When these new variables are substituted by numbers or
            % vectors, the resulting polynomial represents the
            % interpolation of that quantity over the whole finite element.
            
            [~,vi] = IVV.varindexes( newvars );
            vi = vi(vi~=0);
            vcols = setdiff( 1:length(IVV.variables), vi );
            [C,~,IC] = unique( IVV.powers(:,vcols), 'rows' );
            vwts = zeros( size(C,1), numvxs );
            % Can the next loop be made a one-liner?
            for i=1:size(IVV.powers,1)
                ci = IC(i);
                vwts(ci,:) = vwts(ci,:) + IVV.powers(i,vi)*IVV.coefficients(i);
            end
            fe.jacobianVxcombs = vwts;
            nvxcombs = size(C,1);
            fe.isomap = polynomial( [ C, eye(nvxcombs) ], ...
                             ones(nvxcombs,1), ...
                             [isovars,genvars( 'A', nvxcombs )] );
            % fe.isomap represents the isoparametric mapping.
            % The extra variables of fe.isomap represent the linear combinations
            % of vectors given by the rows of vwts.
            % This is equivalent to IV, but is computed automatically,
            % while IV was constructed manually.
            
            % We now need to calculate the partial derivatives of fe.isomap with
            % respect to X, Y, and Z.  What we really need to do then is
            % take a non-commutative product of the three polynomials, and
            % map the resulting coefficients to the determinants computed
            % below.  But our polynomial class is not set up to handle
            % non-commutative products.  So this will have to be done by
            % new code.
            
            % Take the three derivatives.
            fe.isograd = polynomial.zero;
            for i=numisovars:-1:1
                v = isovars{i};
                fe.isograd(i) = fe.isomap.deriv1(v);
            end
            
            % Combine a single monomial from each of these and calculate
            % the corresponding list of powers of X, Y, and Z, and a
            % triple of indexes into the extra variables of fe.isomap.
            switch fe.numdims
                case 1
                    pxyzsize = size(fe.isograd(1).powers,1);
                    pxyz = zeros( pxyzsize, 2 );
                    aaa = zeros( pxyzsize, fe.numdims );
                    for i=1:size(fe.isograd(1).powers,1)
                        px = fe.isograd(1).powers(i,1:fe.numdims);
                        ax = find( fe.isograd(1).powers(i,(fe.numdims+1):end)==1 );
                        pxyz(i,:) = px;
                        aaa(i,:) = ax;
                    end
                    % Delete all rows in which aaa has any repetitions.
                    aaanz = true(size(aaa,1),1);
                case 2
                    pxyzsize = size(fe.isograd(1).powers,1) * size(fe.isograd(2).powers,1);
                    pxyz = zeros( pxyzsize, 2 );
                    aaa = zeros( pxyzsize, fe.numdims );
                    ij = 0;
                    for i=1:size(fe.isograd(1).powers,1)
                        px = fe.isograd(1).powers(i,1:fe.numdims);
                        ax = find( fe.isograd(1).powers(i,(fe.numdims+1):end)==1 );
                        for j=1:size(fe.isograd(2).powers,1)
                            py = fe.isograd(2).powers(j,1:fe.numdims);
                            ay = find( fe.isograd(2).powers(j,(fe.numdims+1):end)==1 );
                            ij = ij+1;
                            pxyz(ij,:) = px + py;
                            aaa(ij,:) = [ax,ay];
                        end
                    end
                    % Delete all rows in which aaa has any repetitions.
                    aaanz = aaa(:,1)~=aaa(:,2);
                otherwise
                    pxyzsize = size(fe.isograd(1).powers,1) * size(fe.isograd(2).powers,1) * size(fe.isograd(3).powers,1);
                    pxyz = zeros( pxyzsize, 3 );
                    aaa = zeros( pxyzsize, fe.numdims );
                    ijk = 0;
                    for i=1:size(fe.isograd(1).powers,1)
                        px = fe.isograd(1).powers(i,1:fe.numdims);
                        ax = find( fe.isograd(1).powers(i,(fe.numdims+1):end)==1 );
                        for j=1:size(fe.isograd(2).powers,1)
                            py = fe.isograd(2).powers(j,1:fe.numdims);
                            ay = find( fe.isograd(2).powers(j,(fe.numdims+1):end)==1 );
                            for k=1:size(fe.isograd(3).powers,1)
                                az = find( fe.isograd(3).powers(k,4:end)==1 );
                                ijk = ijk+1;
                                pxyz(ijk,:) = px + py + fe.isograd(3).powers(k,1:3);
                                aaa(ijk,:) = [ax,ay,az];
                            end
                        end
                    end
                    % Delete all rows in which aaa has any repetitions.
                    aaanz = (aaa(:,1)~=aaa(:,2)) & (aaa(:,1)~=aaa(:,3)) & (aaa(:,2)~=aaa(:,3));
            end
            
            pxyz = pxyz(aaanz,:);
            aaa = aaa(aaanz,:);
            numterms = size(pxyz,1);
            fe.shapeJacobian = polynomial( [pxyz, eye(numterms)], ...
                            ones(numterms,1), ...
                            [ fe.shapeFunctions(1).variables, genvars('A',numterms ) ] );
            fe.detspec = aaa;

            % At every quadrature point, calculate every shape function,
            % and its derivative with respect to every isoparametric
            % coordinate.
            fe.shapequad = zeros( numquadpts, numvxs );
            
            fe.shapederivquad = zeros( numquadpts, fe.numdims, numvxs );
            
            for si=1:numvxs
                fe.shapequad(:,si) = fe.shapeFunctions(si).fulleval( fe.quadraturePoints, 2 );
                shgrad = grad( fe.shapeFunctions(si), fe.shapeFunctions(si).variables );
                for sgi=1:length(shgrad)
                    fe.shapederivquad(:,sgi,si) = shgrad(sgi).fulleval(fe.quadraturePoints);
                end
            end
            fe.shapederivquad = permute( fe.shapederivquad, [3,2,1] );
            
            fe.shapequadproducts = repmat( permute( fe.shapequad, [2,3,1] ), [1,numvxs,1] ) .* ...
                 repmat( permute( fe.shapequad, [3,2,1] ), [numvxs,1,1] );
            fe.shapequadproducts = reshape( fe.shapequadproducts, [], numquadpts );
            fe.Igradquad = polynomial.zero;
            fe.IgradquadVxcombCoeffs = zeros( numisovars, numquadpts, nvxcombs );
            for vi = 1:length(fe.isograd)
                for qi = 1:size(fe.quadraturePoints,1)
                    fe.Igradquad(vi,qi) = fe.isograd(vi).parteval( isovars, fe.quadraturePoints(qi,:) );
                    for k=1:size(fe.Igradquad(vi,qi).powers,1)
                        l = find( fe.Igradquad(vi,qi).powers(k,:)>0, 1 );
                        if ~isempty(l)
                            fe.IgradquadVxcombCoeffs(vi,qi,l) = fe.Igradquad(vi,qi).coefficients(k);
                        end
                    end
                end
            end
            fe.IgradquadVxcombCoeffs = reshape( fe.IgradquadVxcombCoeffs, [], nvxcombs );
            fe.IgradquadVxCoeffs = (fe.IgradquadVxcombCoeffs * fe.jacobianVxcombs)';
                % numvxs [numisovars numquadpts]
        end
        
%         function [I,Igrad,J] = ShapeData( fe, vxcoords )
%             % Calculate the isoparametric mapping, its gradient, and its
%             % Jacobian.
%             % fe is a (type of) finite element, and vxcoords is an N*D
%             % array holding the locations of the N vertexes of a concrete
%             % instance of the finite element.  D is the dimensionaliyy of
%             % the space the concrete element lies in.
%             % I is a list of D polynomials in the isoparametric
%             % coordinates.  I(d) maps the isoparametric coordinates
%             % to the d'th coordinate of that point in the concrete FE.
%             %
%             % Igrad is a V*D array of polynomials in the isoparametric
%             % coordinates, V being the number of isopar coords (necessarily
%             % <= D).  Igrad(v,d) is the d'th coordinate of the derivative
%             % of I with respect to the v'th isopar coord.
%             
%             vars = fe.shapeFunctions(1).variables;
%             vcombs = fe.jacobianVxcombs*vxcoords;
%             dets = makeDeterminants( vcombs, fe.detspec );
%             J = polynomial( fe.shapeJacobian.powers(:,1:fe.numdims), dets, vars );
%             for i=size(vcombs,2):-1:1
%                 I(i) = polynomial( fe.isomap.powers(:,1:fe.numdims), vcombs(:,i), vars );
%                 for j=fe.numdims:-1:1
%                     Igrad(j,i) = fe.isograd(j).parteval( (1:length(fe.isograd(j).variables)) > fe.numdims, vcombs(:,i) );
%                     
%                     % polynomial( fe.isograd(i).powers(:,1:fe.numdims), vcombs(:,j), vars );
%                 end
%             end
%         end
        
%         function J = ShapeJacobian( fe, vxcoords )
%             vcombs = fe.jacobianVxcombs*vxcoords;
%             dets = makeDeterminants( vcombs, fe.detspec );
%             
% %             J2 = fe.shapeJacobian.parteval( [false, false, false, true(1,size(fe.shapeJacobian.powers,1))], ...
% %                     dets );
%             J = polynomial( fe.shapeJacobian.powers(:,1:3), dets, {'X','Y','Z'} );
%         end
        
%         function ev = iso2eucpoly( fe )
%             % Calculate the position in Euclidean coordinates of a point
%             % specified in isoparametric coordinates.
%             
%             ev = polynomial.zero;
%             for i=1:length(fe.shapeFunctions)
%                 ev = ev.sum( ...
%                      fe.shapeFunctions(i).polymult( ...
%                         polynomial( 1, 1, char(64+i) ) ) );
%             end
%         end
        
%         function r = integratepolyabstract( fe, p )
%             pp = p.polymult( fe.shapeJacobian );
%             [vpi,vi] = varindexes( pp, {'X','Y','Z'} );
%             powers = pp.powers(:,vi(vi~=0));
%             variables = pp.variables(:,vi(vi~=0));
%             rc = zeros(size(pp.powers,1),1);
%             for i=1:size(pp.powers,1)
%                 rc(i) = integratepoly( fe, polynomial( powers(i,:), pp.coefficients(i), variables ) );
%             end
%             r = polynomial( pp.powers(:,vpi==0), rc, pp.variables(vpi==0) );
%         end
        
        function [isograd,gradNeuc,weightedJacobian] = interpolationData( fe, vxcoords )
            % Calculate the gradient and Jacobian of the isoparametric
            % mapping at the quadrature points.
            % isograd(D1,D2,Q) is the gradient of the isoparametric mapping
            % at quadrature point Q, where D1 indexes the Euclidean
            % coordinates of the canonical element, and D2 indexes the
            % Euclidean coordinates of the concrete element.
            % gradNeuc(V,D2,Q) is the gradient of shape function V at quad
            % point Q.
            % weightedJacobian(Q) is the determinant of isograd(:,:,Q)
            % multiplied by the Qth quadrature weight.
            
            targetdims = size(vxcoords,2);
            fullshapederivquad = fe.shapederivquad;
            d23 = (fe.numdims==2) && (targetdims==3);
            if d23
                fullshapederivquad(1,3,1) = 0;
            end
            numvxs = size(fe.canonicalVertexes,1);
            numquadpts = size(fe.quadraturePoints,1);
            isograd = reshape( vxcoords' * fe.IgradquadVxCoeffs, targetdims, fe.numdims, numquadpts );
            gradNeuc = zeros( numvxs, targetdims, numquadpts );
            isoJacobian = zeros(numquadpts,1);
            for qi=1:numquadpts
                if d23
                    isograd(:,3,qi) = makeframe( isograd(:,1,qi), isograd(:,2,qi) );
                end
                gradNeuc(:,:,qi) = fullshapederivquad(:,:,qi) / isograd(:,:,qi);
                isoJacobian(qi) = abs(det( isograd(:,:,qi) ));
            end
            weightedJacobian = isoJacobian .* fe.quadratureWeights;
        end
        
        function vq = interpolateQuad( fe, v )
            % Interpolate the quantity V (one element per vertex) at the
            % quadrature points.  V must be a V*N array, where V is the
            % number of vertexes of the element.  The result is Q*N, where
            % Q is the number of quadrature points.
            
            vq = fe.shapequad * v;
        end
        
        function print( fe, fid )
            if nargin < 2
                fid = 1;
            end
            
            fprintf( fid, 'Name: %s', fe.name );
            if fe.numdims==2
                fprintf( fid, ' (2D element)\n' );
            else
                fprintf( fid, ' (3D element)\n' );
            end
            
            fprintf( fid, 'Canon verts:\n' );
            for i=1:size(fe.canonicalVertexes,1)
                fprintf( fid, '    ' );
                fprintf( fid, ' %8.4f', fe.canonicalVertexes(i,:) );
                fprintf( fid, '\n' );
            end
            
            for i=1:length(fe.shapeFunctions)
                fprintf( fid, 'Shape function %d\n', i );
                fe.shapeFunctions(i).print(fid);
                fprintf( fid, '\n' );
            end
            
            fprintf( fid, 'Quadrature:\n' );
            for i=1:size(fe.quadraturePoints,1)
                fprintf( fid, '    [' );
                fprintf( fid, ' %8.4f', fe.quadraturePoints(i,:) );
                fprintf( fid, ' ]: ' );
                fprintf( fid, ' %f', fe.quadratureWeights(i) );
                fprintf( fid, '\n' );
            end
        end
        
        function drawFE( fe, vxcoords )
            if nargin < 2
                vxcoords = fe.canonicalVertexes;
            end
            cla
            scatterPosNeg( fe.quadraturePoints, fe.quadratureWeights, 100 );
            plotmesh( vxcoords, 1:size(vxcoords,1), fe.edges );
        end
        
        function validityChecks( fe )
            % Validity tests.
            
            fprintf( 1, 'Validity test of finite element type %s.\n', fe.name );
            
            %   Shape functions should add to 1.
            p = fe.shapeFunctions(1);
            for i=2:length( fe.shapeFunctions )
                p = p.sum( fe.shapeFunctions(i) );
            end
            fprintf( 1, 'The shape functions should add to 1.\n' );
            p.reduce.print
            
            % Each shape function should be 1 at the corresponding vertex
            % at 0 at all other vertexes.
            nvxs = size(fe.canonicalVertexes,1);
            sfv = zeros(nvxs,nvxs);
            for i=1:nvxs
                for j=1:nvxs
                    sfv(i,j) = fe.shapeFunctions(i).fulleval( fe.canonicalVertexes(j,:), 2 );
                end
            end
            fprintf( 1, 'Evaluating the shape functions at the canonical vertexes should give the identity.\n' );
            sfverr = sfv - eye(size(sfv));
            sfverr = max(abs(sfverr(:)));
            for i=1:size(sfv,1)
                fprintf( 1, '    ' );
                fprintf( 1, ' %4g', sfv(i,:) );
                fprintf( 1, '\n' );
            end
            fprintf( 1, '    Maximum error is %g.\n', sfverr );
            
            %   For any point V, V should be equal to the sum of the shape
            %   functions at V multiplying the respective canonical
            %   vertexes.
            dims = size(fe.canonicalVertexes,2);
            v0 = rand(1,dims);
            v = zeros(1,dims);
            for i=1:nvxs
                t = fe.shapeFunctions(i).fulleval( v0, 2 );
                v = v + t*fe.canonicalVertexes(i,:);
            end
            fprintf( 1, 'Isoparametric test: these two vectors should be equal:\n    ' );
            fprintf( 1, ' %8.4f', v0 );
            fprintf( 1, '\n    ' );
            fprintf( 1, ' %8.4f', v );
            fprintf( 1, '\nDifference:\n    ' );
            fprintf( 1, ' %8.2g', v0-v );
            fprintf( 1, '\n' );
            
            % The next test cannot be done unless we have some more direct
            % way to measure the size of an arbitrary finite element.  We
            % could generate a regular grid of the isopar coords and
            % numerically integrate that.
%             fprintf( 1, 'Numerical integration of the Jacobian should be exact.\n' );
%             
%             vxcoords = fe.canonicalVertexes + 0.1*rand(size(fe.canonicalVertexes));
%             Igradvalues2 = reshape( vxcoords' * fe.IgradquadVxCoeffs, size(vxcoords,2), fe.numdims, numquadpts );
% 
%             gradNeuc = zeros( numvxs, size(nodecoords,2), numquadpts );
%             Ijacobians = zeros(numquadpts,1);
%             for qi=1:numquadpts
%                 gradNeuc(:,:,qi) = fe.shapederivquad(:,:,qi) / Igradvalues2(:,:,qi);
%                 Ijacobians(qi) = abs(det( Igradvalues2(:,:,qi) ));
%             end
%             IntJ = sum( (fe.quadratureWeights .* Ijacobians) );
%             fprintf( 1, '    IntJ %f, volume %f, error %g.\n', IntJ, volume, IntJ - volume );
        end
        
        function fe = upgradeFE( fe )
            % Empty so far.
        end
    end
end

function [b,s,d,g] = parseSpec( spec )
%[b,s,d,g] = parseSpec( spec )
%   Read the name of a finite element type and extract:
%       b: the number of box dimensions
%       s: the number of simplex dimensions
%       d: the degree of the element
%       g: the degree of Gaussian quadrature
%   Specifications have the form Bn-Sn-Dn-Gn.  The B or S elements may be
%   omitted if the associated number is zero.

    [a,c,e] = sscanf( spec, 'B%d-S%d-D%d-G%f' );
    if ((c == 4) || isempty(e))
        b = a(1);  s = a(2);  d = a(3);  g = a(4);
        return;
    end
    [a,c,e] = sscanf( spec, 'S%d-D%d-G%f' );
    if ((c == 3) || isempty(e))
        b = 0;  s = a(1);  d = a(2);  g = a(3);
        return;
    end
    [a,c,e] = sscanf( spec, 'B%d-D%d-G%f' );
    if ((c == 3) || isempty(e))
        b = a(1);  s = 0;  d = a(2);  g = a(3);
        return;
    end
    b = 0; s = 0; d = 0; g = 0;
end
