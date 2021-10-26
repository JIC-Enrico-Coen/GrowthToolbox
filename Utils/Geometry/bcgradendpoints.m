function gradendpoints = bcgradendpoints( v, bc, vxs )
%pts = bcgradendpoints( v, bc, vxs )
%   Given v, a vector of the three values of some scalar at the vertexes
%   vxs of a triangle, and bc, the bcs of a point in the triangle.
%   Compute the bcs of the intersection of the line parallel to the
%   gradient vector of v through the point bc with the three sides of the
%   triangle.

    p = bcisoendpoints( v, bc );
    isobc = p(:,find(all(isfinite(p),1),1)) - bc(:);
    r3 = isobc'*vxs*vxs';
    gradendpoints = bcisoendpoints( r3, bc );
end
