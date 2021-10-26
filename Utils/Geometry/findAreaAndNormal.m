function [a,n] = findAreaAndNormal( vxs )
%[a,n] = findAreaAndNormal( vxs )
%   Compute the normal vector and area of a triangle whose vertices are the
%   rows of vxs.  We do these together, since this is faster than computing
%   them separately.

    n = trinormal( vxs );
    a = norm(n);
    n = n/a;
    a = a/2;
end
