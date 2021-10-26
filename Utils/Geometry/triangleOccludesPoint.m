function [occludes,k] = triangleOccludesPoint( tri, pt, dir, tol )
%triangleOccludesPoint( tri, pt, dir, tol )
% Determine whether the directed line with direction DIR through point PT
% intersects the triangle TRI (a matrix of three row vectors) before
% hitting the point.
%
% OCCLUDES is a boolean that is true if the point is occluded.
% K is a measure of the distance between the point and the plane of the
% triangle along DIR.  If DIR is a unit vector, K is the distance, which
% will always be negative when OCCLUDES is true.  When OCCLUDES is false it
% may have any value.
%
% TOL is a tolerance and defaults to 0. When TOL is negative, the
% calculation is carried out as though the triangle were slightly smaller
% than it is.  Thus a point which is only just obscured by the triangle is
% counted as not obscured.  If TOL is positive, the opposite happens: the
% triangle is treated as slightly larger than it is.  The actual test is
% that if k >= tol, the triangle does not occlude the point.
    
    if nargin < 4
        tol = 0;
    end
    a = tri(2,:)-tri(1,:);
    b = tri(3,:)-tri(1,:);
    k = -det( [a;b;pt-tri(1,:) ] ) / det( [a;b;dir ] );
    p = pt + k*dir;
    if k >= tol
        occludes = false;
    else
        bc = baryCoords( tri, [], p );
        occludes = all(bc >= 0);
    end
end
