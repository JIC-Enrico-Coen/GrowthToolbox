function in = invertArray( a, v )
%in = invertArray( a, v )
%in = invertArray( a )
%   Given an array A and an array V of values, return the
%   indexes of the first elements of A having those values.  The result is
%   always the same shape as V, and for any value in V not found in the
%   array, zero is returned.  A is treated as 1-dimensional.
%
%   If V is omitted, it is taken to be 1:round(max(A(:))).  If A is a
%   permutation of this, then IN is the inverse permutation, although this
%   can be calculated more simply by writing IN(A) = 1:numel(A).

    if nargin < 2
        v = 1:round(max(a(:)));
    end

    if numel(v)==1
        in = find( a==v, 1 );
        if isempty(in)
            in = 0;
        end
    else
        [c,ia,~] = unique(a,'sorted');
        in = zeros(size(v));
        [vs,vp] = sort(v(:));
        ci = 1;
        vsi = 1;
        nv = numel(v);
        nc = length(c);

        while (vsi <= nv) && (ci <= nc)
            if c(ci) < vs(vsi)
                ci = ci+1;
            else
                if c(ci)==vs(vsi)
                    in(vp(vsi)) = ia(ci);
                end
                vsi = vsi+1;
            end
        end
    end
end
