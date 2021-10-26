function [areas,normals] = triangleareas( nodes, triangles )
%[areas,normals] = triangleareas( nodes, triangles )
%   Calculate the areas and normal vectors for a set of triangles in
%   2D or 3D space.  PTS is an N*2 or N*3 array
%   of N points, and triangles is a K*3 array of indexes to the rows of
%   PTS.
%
%   When the area of a triangle is zero, the corresponding normal has NaN
%   as all of its components.  The area is always non-negative.
%
%   The sense of the normal vector follows the right-hand rule: if the
%   right hand makes a fist with the thumb extended in the direction of the
%   normal vector, the order of the vertexes follows the direction of the
%   fingers.
%
%   In 2D, the normal vector will be [0 0 1] if the vertexes are listed
%   clockwise, [0 0 -1] if anticlockwise, or [Nan NaN NaN] if the triangle
%   is degenerate.

    v1 = nodes( triangles(:,1), : );
    v2 = nodes( triangles(:,2), : );
    v3 = nodes( triangles(:,3), : );
    if size(nodes,2) < 3
        z = zeros( size(v1,1), 1 );
        v1 = [ v1, z ];
        v2 = [ v2, z ];
        v3 = [ v3, z ];
    end
    v12 = v2-v1;
    v13 = v3-v1;
    normals = cross( v12, v13, 2 );
    areas = sqrt( sum( normals.*normals, 2 ) );
    for i=1:size(normals,2)
        normals(:,i) = normals(:,i) ./ areas;
    end
    areas = areas/2;
end
