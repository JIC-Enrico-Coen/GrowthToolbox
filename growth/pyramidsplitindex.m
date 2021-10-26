function [i, j, k] = pyramidsplitindex( n )
%[i, j, k] = pyramidsplitindex( n )
%ijk = pyramidsplitindex( n )
%   Given an integer N >= 0, find the triple [i,j,k] that are the
%   coordinates of point number N in the infinite tetrahedral pyramid.
%   N may be an array of any shape.
%   The first form returns i, j, and k separately, each having the same
%   shape as n.  The second returns them as a numel(N)*3 matrix.
%
%   In all cases, we have pyramidindex( pyramidsplitindex( n ) ) == n and
%   pyramidsplitindex( pyramidindex( ijk ) ) == ijk 
%
%   See also: pyramidindex.

    i = zeros(size(n));
    j = zeros(size(n));
    k = zeros(size(n));
    for ni=1:numel(n)
        r = n(ni);
        s = 0;
        for z=0:(r+1);
            s1 = (z*(z+1)*(z+2))/6;
            if s1 > r
                layer = z-1;
                r = r - s;
                break;
            end
            s = s1;
        end
        s = 0;
        for z=0:(r+1);
            s1 = (z*(z+1))/2;
            if s1 > r
                row = z-1;
                r = r - s;
                break;
            end
            s = s1;
        end
        k(ni) = r;
        j(ni) = row-r;
        i(ni) = layer-row;
    end
    if nargout < 3
        i = [i(:) j(:) k(:)];
    end
end
