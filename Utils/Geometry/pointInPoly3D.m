function [inside,bc] = pointInPoly3D( pt, poly, tol )
%bc = pointInPoly3D( pt, poly )
%   Determine whether the given point is in the given polygon in 3D space.
%   The polygon is assumed to be flat and strictly convex.
%   If the point is inside, the result is a set of barycentric coordinates for the point in terms
%   of three of the vertices of the polygon, otherwise the result is empty.
%   This procedure is not particularly efficient.

    inside = false;
    bc = [];
    if size(poly,1) < 3
        return;
    end
    if nargin < 3
        tol = 1e-6;
    end
    n = [];
    dims = size(poly,2);
    for i = 2:(size(poly,1)-1)
        vxs = poly([1 i i+1],:);
        if dims==2
            bc1 = baryCoordsN( vxs, pt );
        else
            bc1 = baryCoords( vxs, [], pt );
        end
        if all(bc1 >= -tol)
            bc = zeros(1,size(poly,1));
            bc([1 i i+1]) = bc1;
            inside = true;
            return;
        end
    end
end
