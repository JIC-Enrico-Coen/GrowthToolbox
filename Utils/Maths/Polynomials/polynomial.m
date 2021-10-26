classdef polynomial
    
    properties
        variables = {};
        powers = [];
        coefficients = [];
    end

    methods (Static)
        
        function p = lagrangePoly( n, k, vals, var )
            if nargin < 4
                var = 'X';
            end
            p = polynomial.constant( 1, var );
            for i=0:n
                if i ~= k
                    p = polymult( p, polynomial( [0;1], [-vals(i+1),1]/(vals(k+1)-vals(i+1)), var ) );
                end
            end
        end
        
        function p = polynomial( pows, coeffs, vars )
            if nargin==0
                return;
            end
            % Create a polynomial.
            if (nargin < 3) || isempty(vars)
                vars = cell(1,size(pows,2));
                for i=1:length(vars)
                    vars{i} = char(64+i);
                end
            end
            if ischar(vars)
                vars = { vars };
            end
            nonzero = coeffs ~= 0;
            p.powers = pows(nonzero,:);
            p.coefficients = coeffs(nonzero);
            p.coefficients = p.coefficients(:);
%             [p.powers,perm] = sortrows( p.powers );
%             p.coefficients = p.coefficients(perm);
            p.variables = vars;
        end
        
        function p = zero( vars )
            % Create a zero polynomial.
            if nargin==0
                p = polynomial( [], [] );
            else
                p = polynomial( [], [], vars );
            end
        end
        
        function p = constant(k,vars)
            % Create a constant polynomial with value K.
            if (nargin < 2) || isempty(vars)
                vars = {'A'};
            end
            p = polynomial( zeros(1,length(vars)), k, vars );
        end
        
        function [p,q] = unitevars( p, q )
            % Arrange that p and q have the same variables in the same order.
            if length(p.variables)==length(q.variables)
                % If they already do, do nothing.
                same = true;
                for i=1:length(p.variables)
                    if ~strcmp(p.variables{i},q.variables{i})
                        same = false;
                        break;
                    end
                end
                if same
                    return;
                end
            end
            [vpi,vi] = p.varindexes( q.variables );
            % vars_common = p.variables(vpi~=0);
            vars_pnotq = p.variables(vpi==0);
            vars_qnotp = q.variables(vi==0);
            
            p.powers = [ p.powers, zeros( size(p.powers,1), length(vars_qnotp) ) ];
            p.variables = [ p.variables, vars_qnotp ];
            [p.variables,perm_p] = sort( p.variables );
            p.powers = p.powers(:,perm_p);
            
            q.powers = [ q.powers, zeros( size(q.powers,1), length(vars_pnotq) ) ];
            q.variables = [ q.variables, vars_pnotq ];
            [q.variables,perm_q] = sort( q.variables );
            q.powers = q.powers(:,perm_q);
            
            
            
%             [v,ia,ib] = union( p.variables, q.variables );
%             if length(v) > size(p.powers,2)
%                 pows = zeros( size(p.powers), length(v) );
%                 pows(:,ia) = p.powers;
%                 p = polynomial( pows, p.coefficients, v );
%             end
%             if length(v) > size(q.powers,2)
%                 pows = zeros( size(q.powers), length(v) );
%                 pows(:,ib) = q.powers;
%                 q = polynomial( pows, q.coefficients, v );
%             end
%             p = p.includevars( v );
%             q = q.includevars( v );
        end
    end
    
    methods
        function print( p, fid )
            % Print a polynomial to a file descriptor FID.
            if nargin < 2
                fid = 1;
            end
            if ~isempty( p.variables )
                fprintf( fid, ' %3s', p.variables{:} );
                fprintf( fid, '\n' );
            end
            if isempty( p.powers )
                fprintf( fid, '    ZERO\n' );
            else
                for i=1:size(p.powers,1)
                    fprintf( fid, ' %3d', p.powers(i,:) );
                    fprintf( fid, ' %8g\n', p.coefficients(i) );
                end
            end
        end
        
        function d = degree( p )
            % Find the maximum degree of a polynomial.
            d = max(sum(p.powers,2));
        end
        
        function r = sum( p, q )
            % Find the sum of two polynomials.
            [p,q] = polynomial.unitevars( p, q );
            r = polynomial( [ p.powers; q.powers ], [ p.coefficients; q.coefficients ], p.variables );
            r = r.reduce;
        end
        
        function r = diff( p, q )
            % Find the difference between two polynomials.
            [p,q] = polynomial.unitevars( p, q );
            r = polynomial( [ p.powers; q.powers ], [ p.coefficients; -q.coefficients ], p.variables );
            r = r.reduce;
        end
        
        function q = scalarmult( p, k )
            % Multiply a polynomial by a real number, or an array of real numbers.
            %q = polynomial( p.powers, p.coefficients*k, p.variables );
            
            
            if numel(k)==1
                q = polynomial( p.powers, p.coefficients*k, p.variables );
            else
                q(numel(k)) = polynomial.zero;
                for i=1:numel(k)
                    k1=k(i);
                    q(i) = polynomial( p.powers, p.coefficients*k1, p.variables );
                end
                q = reshape(q,size(k));
            end
        end
        
        function r = square( p )
            % Find the square of a polynomial.
            r = polymult( p, p );
        end
        
        function r = polypower( p, n )
            % Raise a polynomial to an integer power.
            s = dec2bin(n);
            r = p;
            for i=2:length(s)
                r = r.square();
                if s(i)=='1'
                    r = r.polymult(p);
                end
            end
        end
        
        function r = polymult( p, q )
            % Find the product of two polynomials.
            [p,q] = polynomial.unitevars( p, q );
            pt = size(p.powers,1);
            qt = size(q.powers,1);
            pows = zeros( pt*qt, size(p.powers,2) );
            k = 0;
            for i=1:size(p.powers,1)
                for j=1:size(q.powers,1)
                    k = k+1;
                    pows(k,:) = p.powers(i,:) + q.powers(j,:);
                end
            end
            coeffs = reshape( q.coefficients * p.coefficients', [], 1 );
            r = polynomial( pows, coeffs, p.variables );
            r = r.reduce;
        end
        
        function p = reduce( p, tol, options )
            % Reduce a polynomial to a canonical form.
            % There are five transformations, two of which are optional and
            % by default are not done.  These are the elimination of unused
            % variables, and the sorting of variables.
            % Supplying options='all' will perform all transformations.
            % Otherwise, options can be a string possibly containing a 'u'
            % (eliminate unused variables) or a 's' (sort variables).
            % The reason for making these optional is because sometimes it
            % is convenient to work with polynomials having a known set of
            % variables in a known order.
            
            if nargin < 3
                deleteUnusedVariables = false; 
                sortVariables = false; 
            elseif strcmp(options,'all')
                deleteUnusedVariables = true; 
                sortVariables = true; 
            else
                deleteUnusedVariables = find('u'==options);
                sortVariables = find('s'==options);
            end
            
            % 1. Collect multiple instances of the same monomial together,
            % adding the corresponding coefficients.
            [pows,~,ir] = unique( p.powers, 'rows' );
            coeffs = zeros( size(pows,1), 1 );
            for i=1:length(ir)
                coeffs(ir(i)) = coeffs(ir(i)) + p.coefficients(i);
            end
            
            % 2. Eliminate zero coefficients.  If a tolerance is specified,
            % consider any coefficient less than or equal to it to be zero,
            % otherwise only delete terms where the coefficient is exactly
            % zero.
            if (nargin < 2) || isempty(tol)
                nz = coeffs ~= 0;
            else
                nz = abs(coeffs) > tol;
            end
            if ~any(nz)
                if deleteUnusedVariables
                    p = polynomial.zero( p.variables{1} );
                else
                    p = polynomial.zero( p.variables );
                end
                return;
            end
            p.powers = pows(nz,:);
            p.coefficients = coeffs(nz);
            
            % 3. Optionally, eliminate unused variables.
            if deleteUnusedVariables
                used = any( p.powers > 0, 1 );
                if ~any(used)
                    p = polynomial.constant( sum( p.coefficients ), p.variables{1} );
                    return;
                end
                p.powers = p.powers(:,used);
                p.variables = p.variables(used);
            end
            
            % 4. Optionally, sort the variables.
            if sortVariables
                [p.variables,perm] = sort( p.variables );
                p.powers = p.powers(:,perm);
            end
            
            % 5. Sort the monomials.
            [p.powers,perm] = sortrows( p.powers );
            p.coefficients = p.coefficients(perm);
        end
        
        function p = addvars( p, vars )
            % Force the polynomial P to include all of the given variables,
            % which are assumed not to occur in p.
            if ischar(vars)
                vars = { vars };
            end
            if p.iszero()
                p.variables = vars;
                p.powers = zeros(0,length(vars));
            else
                p.powers = [ p.powers, zeros(size(p.powers,1),length(vars)) ];
                p.vars = [ p.variables, vars ];
            end
        end
        
        function p = includevars( p, vars )
            % Force the polynomial P to include all of the given variables.
            % The variables may occur in p already.
            if ischar(vars)
                vars = { vars };
            end
            if p.iszero()
                p.variables = vars;
                p.powers = zeros(0,length(vars));
            else
                unionvars = [ p.variables, vars ];
                [newvars,~,ic] = unique(unionvars);
                if length(newvars) > length(p.variables)
                    pows = zeros( size(p.powers,1), length(newvars) );
                    pows(:,ic(1:length(p.variables))) = p.powers;
                    p.powers = pows;
                    p.variables = newvars;
                end
            end
        end
        
        function p = limitvars( p, vars )
            % Eliminate all variables from p except those listed, by
            % setting them to zero.
            
            if ischar(vars)
                vars = { vars };
            end
            if islogical(vars)
                vpi = ~vars;
            else
                [vpi,~] = varindexes( p, vars );
                vpi = vpi==0;
            end
            p = setVarsZero( p, vpi );
        end
        
        function p = setVarsZero( p, vars )
            if ischar(vars)
                vars = { vars };
            end
            if islogical(vars)
                vpi = vars;
            else
                [vpi,~] = varindexes( p, vars );
            end
            zeroterms = any( p.powers(:,vpi) > 0, 2 );
            p.powers(:,vpi) = [];
            p.powers(zeroterms,:) = [];
            p.coefficients(zeroterms) = [];
            p.variables(vpi) = [];
            p = reduce(p);
        end
        
        function p = parteval( p, vars, vals )
            % Partially evaluate P, by setting each variable in VARS to
            % the corresponding real number in VALS, giving another
            % polynomial.  VARS may validly include variables not occurring
            % in P; these are ignored.  If VARS includes all the variables
            % in P, the result is still returned as a (constant)
            % polynomial, not a real number.
            % VARS may alternatively be a boolean map of the variables to
            % be substituted.
            if p.isconstant()
                return;
            end
            
            if ischar(vars)
                % vars is the name of a single variable.  Make it a cell
                % array.
                vars = { vars };
            end
            
            if islogical(vars)
                % vars is a bitmap of all the variables of p.
                vpi = vars;
            else
                % vars is a cell array of names of variables.
                [vpi,vi] = varindexes( p, vars );
                vals = vals(vi>0);
            end
            evalitems = p.powers(:,vpi>0);
            for i=1:size(evalitems,2)
                evalitems(:,i) = vals(i).^evalitems(:,i);
            end
            evalitems = prod( evalitems, 2 );
            p.coefficients = p.coefficients .* evalitems;
            p.powers = p.powers(:,vpi==0);
            p.variables = p.variables(vpi==0);
            p = p.reduce();
        end
        
        function r = fulleval( p, vals, dim )
            % Evaluate P to a real number, setting each variable to
            % the corresponding real number in VALS, which is assumed to
            % list the values in the same order as the variables of P.
            % VALS must be the same length as the number of variables in P.
            % VALS may also be an array of any number of dimensions, in
            % which case one dimension, specified by DIM, is taken to be
            % the dimension along which variable identity varies, and the
            % effect is to evaluate P at all of the points on the other
            % dimensions of VALS.  The result will be an array the same
            % shape as VALS, except that its size in dimension DIM will be
            % 1.
            
            numvars = length(p.variables);
            sv = size(vals);
            if numel(vals)==numvars
                vals = vals(:);
            elseif numvars==1
                vals = vals(:);
            else
                if nargin < 3
                    dim = find( sv==numvars, 1 );
                    if isempty(dim)
                        error( 'fulleval: no dimension of VALS is the right size.' );
                    end
                end
                if dim > length(sv)
                    error( 'fulleval: specified dimension %d is not present in VALS.', dim );
                end
                if sv(dim) ~= numvars
                    error( 'fulleval: specified dimension %d has size %d, number of variables is %d.', ...
                        dim, sv(dim), numvars );
                end
                dperm = [dim, 1:(dim-1), (dim+1):length(sv)];
                vals = reshape( permute( vals, dperm ), numvars, [] );
            end
            r = zeros(1,size(vals,2));
            % POSSIBLE IMPROVEMENT: There's some recalculation of powers
            % of VALS that could be avoided.
            for i=1:size(p.powers,1)
                v1 = 1;
                for j=1:numvars
                    v1 = v1 .* vals(j,:).^p.powers(i,j);
                end
                r = r + v1 * p.coefficients(i);
            end
            if numel(vals)==numvars
                % Nothing.
            elseif numvars==1
                r = reshape( r, sv );
            else
                rsize = [ sv(1:(dim-1)), 1, sv((dim+1):length(sv)) ];
                r = reshape( r, rsize );
            end
        end
        
        function r = fullevalX( p, vars, vals )
            % Evaluate P to a real number, setting each variable in VARS to
            % the corresponding real number in VALS.  VARS must include all
            % of the variables of P or an error is raised.  VARS may
            % validly include variables not occurring in P; these are
            % ignored.
            if ischar(vars)
                vars = { vars };
            end
            q = parteval( p, vars, vals );
            if ~isconstant(q)
                error( 'fulleval did not yield a constant, first variable is ''%s''', ...
                    q.variables{1} );
            end
            if isempty( q.coefficients )
                r = 0;
            else
                r = q.coefficients(1);
            end
        end
        
        function isz = iszero( p )
            % Determine whether P is zero.
            isz = all( p.powers(:)==0 ) && all( p.coefficients==0 );
        end
        
        function isc = isconstant( p )
            % Determine whether P is constant.
            isc = all( p.powers(:)==0 );
        end
        
        function ish = ishomogeneous( p )
            % Determine whether all the terms of P have the same total
            % power.
            totalpowers = sum( p.powers, 2 );
            ish = isempty(totalpowers) || all(totalpowers==totalpowers(1));
        end
        
        function isv = isvalid( p )
            % Make some valid validity check on the polynomial P.
            isv = (length(p.variables)==size(p.powers,2)) && (length(p.coefficients)==size(p.powers,1));
        end
        
        function q = deriv1( p, v )
            % Calculate the derivative of P with respect to a single
            % variable V.
            if ischar(v)
                v = { v };
            end
            [~,vi] = p.varindexes({v});
            if vi==0
                q = polynomial.zero( p.variables );
            else
                nz = p.powers(:,vi) ~= 0;
                if ~any(nz)
                    q = polynomial.zero( p.variables );
                else
                    pows = p.powers(nz,:);
                    coeffs = p.coefficients(nz) .* pows(:,vi);
                    pows(:,vi) = pows(:,vi) - 1;
                    q = polynomial( pows, coeffs, p.variables );
                end
            end
        end
        
        function q = grad( p, vars )
            if nargin==1
                vars = p.variables;
            end
            for i=length(vars):-1:1
                q(i) = p.deriv1( vars{i} );
            end
        end
        
        function q = integral1( p, v, lo, hi )
            % Calculate the definite or indefinite integral of P with
            % respect to a single variable V.
            % LO and HI, if specified, are the bounds of the integration,
            % and must be real numbers.  (They cannot themselves be
            % polynomials.)
            % If LO is omitted or empty, it defaults to zero.
            % If HI is omitted or empty, the upper limit is the variable V,
            % giving the indefinite integral.
            if ischar(v)
                v = { v };
            end
            if (nargin < 3) || isempty(lo)
                lo = 0;
            end
            if nargin < 4
                hi = [];
            end
            [~,vi] = p.varindexes({v});
            if vi==0
                % not implemented
                p = p.includevars({v});
                [~,vi] = p.varindexes({v});
            end
            pows = p.powers;
            pows(:,vi) = pows(:,vi) + 1;
            coeffs = p.coefficients ./ pows(:,vi);
            q = polynomial( pows, coeffs, p.variables );
            if lo ~= 0
                q = q.diff( q.parteval( {v}, lo ) );
            end
            if ~isempty(hi)
                q = q.parteval( {v}, hi );
            end
        end
        
        function [vpi,vi] = varindexes( p, vars )
            % VPI is an array of possible indexes into VARS, whose length
            % is the number of variables in P.  VPI(I) is zero if the I'th
            % variable of P is not in VARS, and is the position of that
            % variable in VARS otherwise.
            % VI is the opposite: VI(I) is zero if the I'th member of VARS
            % is not a variable of P, and otherwise is the position of that
            % variable in P.VARIABLES.
            if ischar(vars)
                vars = { vars };
            end
            vpi = zeros(1,length(p.variables));
            vi = zeros(1,length(vars));
            for j=1:length(vars)
                for i=1:length(p.variables)
                    if strcmp( p.variables{i}, vars{j} )
                        vpi(i) = j;
                        vi(j) = i;
                        break;
                    end
                end
            end
        end
        
        function p = renamevars( p, v, w )
            % Rename variables v to w.  The variables v must occur in p,
            % and w must not include any variable in p and not in v.
            % Neither v nor w may contain repeated variables.
            if ischar(v)
                v = {v};
            end
            if ischar(w)
                w = {w};
            end
            [~,vi] = p.varindexes(v);
            p.variables(vi) = w;
        end
        
        function r = substitute( p, v, q )
            % Calculate the polynomial resulting from replacing variable V
            % in P by polynomial Q.
            
            [~,vi] = p.varindexes({v});
            if vi==0
                % V does not occur in P.  The result is P itself.
                r = p;
                return;
            end
            
            % Sort the terms of P by power of V.
            vpows = p.powers(:,vi);
            [vpows,vpi] = sort(vpows);
            p.powers = p.powers(vpi,:);
            p.coefficients = p.coefficients(vpi);
            
            % Find blocks of terms with the same power of V.
            vsteps = find( vpows(1:(end-1)) ~= vpows(2:end) );
            vlo = [1, vsteps'+1];
            vhi = [vsteps', length(vpows)];
            % Columns of P.POWERS other than V.
            nonv = (1:size(p.powers,2)) ~= vi;
            if isempty(nonv)
                % V is the only variable of P.  This is an awkward edge
                % case
            end
            
            % Initialise the result and some loop variables.
            r = polynomial.zero();
            qq = q;      % The latest computed power of Q.
            qpower = 1;  % The exponent of that power.
            
            % For each block...
            for i=1:length(vlo)
                % Form the polynomial R1 consisting of those terms of P
                % having the power of V in the i'th block, with V removed.
                rows = vlo(i):vhi(i);
                r1 = polynomial( p.powers(rows,nonv), p.coefficients(rows), p.variables(nonv) );
                vp = vpows(vlo(i));
                if vp==0
                    % V has power zero, so substituting Q for V has no
                    % effect.  If nonv is empty  we have an edge case that
                    % needs to be worked around.
                    if ~any(nonv)
                        r1 = r1.includevars( q.variables );
                    end
                else
                    % Calculate the required power of Q.
                    while qpower < vp
                        qq = qq.polymult(q);
                        qpower = qpower+1;
                    end
                    % Multiply R1 by that power of Q.
%                     fprintf( 1, 'r1a\n' );
%                     r1.print();
                    r1 = r1.polymult( qq );
%                     fprintf( 1, 'qq\n' );
%                     qq.print();
%                     fprintf( 1, 'r1b\n' );
%                     r1.print();
                end
                % Add the polynomial R1 to the result.
                r = r.sum( r1 );
            end
        end
        
    end
    
end
