function [areas,normals,volumes] = quadareas( pts, quads )
%[areas,normals] = quadareas( pts, quads )
%[areas,normals,volumes] = quadareas( pts, quads )
%
%   Calculate the areas and normal vectors for a set of quadrilaterals in
%   2D or 3D space.  The quadrilaterals need not be planar.  PTS is an N*2
%   or N*3 array of N points, and quads is a K*4 array of indexes to the
%   rows of PTS. The vertexes are listed in order around each
%   quadrilateral.
%
%   The normal vector is calculated as the common perpendicular to the
%   diagonals. The area is always non-negative.  If the area is zero, the
%   normal has NaN as all of its components.
%
%   The sense of the normal vector follows the right-hand rule: if the
%   right hand makes a fist with the thumb extended in the direction of the
%   normal vector, the order of the four vertexes follows the direction of
%   the fingers.
%
%   For non-planar quadrilaterals, the values returned for the area and
%   normal still have exact geometric definitions, although whether they
%   are useful concepts will depend on the application.  The calculated
%   area is the area of the planar quadrilateral resulting from projecting
%   the given quadrilateral onto a plane along the normal vector.
%
%   If the quadrilateral is planar, but self-intersecting to make a bow-tie
%   shape, the calculated area will be the difference between the two
%   triangles that make up the shape.  For such a shape it is possible for
%   the area to be zero although the points are not collinear.
%
%   If the third output argument is requested, the volume of space enclosed
%   by each quadrilateral is returned.  This is the volume of the
%   tetrahedron that is the convex hull of the four vertexes. The ratio of
%   this to the area is a measure of how non-planar it is. Specifically, it
%   is one third of the distance between the two diagonals, measured along
%   their common normal.  It is always defined, even if the normal is not
%   (in which case the volume is zero).
%
%   The volume may be positive or negative, and will be zero only for a
%   planar quadrilateral.  The volume will be positive if, standing at
%   vertex 1 and looking towards the triangle formed by vertexes 2, 3, and
%   4, these vertexes in that order are seen in clockwise order.
%
%   See also: triangleareas.

    if size(pts,2)<3
        pts = [ pts, zeros(size(pts,1),3-size(pts,2)) ];
    end
    A = pts(quads(:,3),:) - pts(quads(:,1),:);
    B = pts(quads(:,4),:) - pts(quads(:,2),:);
    normals = crossproc2(A,B);
    areas = sqrt(sum(normals.*normals,2));
    normals = normals./repmat(areas,1,3);
    areas = areas/2;
    if nargout >= 3
        V1 = pts(quads(:,2),:) - pts(quads(:,1),:);
        V2 = pts(quads(:,4),:) - pts(quads(:,1),:);
        volumes = (V1(:,1).*A(:,2).*V2(:,3) ...
                    + V1(:,2).*A(:,3).*V2(:,1) ...
                    + V1(:,3).*A(:,1).*V2(:,2) ...
                    - V1(:,1).*A(:,3).*V2(:,2) ...
                    - V1(:,2).*A(:,1).*V2(:,3) ...
                    - V1(:,3).*A(:,2).*V2(:,1) )/6;
    end
end
