function bc = baryCoordsN( vxs, v )
%bc = baryCoordsN( vxs, v )
%   Calculate the barycentric coordinates of point v with respect to a
%   simplex vxs.  In N dimensions, vxs must be an (N+1)*N maxtrix,
%   containing N+1 points.  v can be a K*N matrix, of K N-dimensional
%   points.  The results is a K*(N+1) matrix of K sets of barycentric
%   coordinates.
%
%   tetrahedron vxs, in three dimensions.  vxs contains the four vertexes of
%   the tetrahedron as rows.
%   n and v must be row vectors, and the result is a 3-element row vector.
%   v can also be a matrix of row vectors; the result will then be a matrix
%   of 3-element row vectors.
%
%   This procedure works in any number of dimensions.
%
%   A result will still be returned if vxs contains fewer or more points
%   and N+1, or if the points all lie in a subspace of smaller dimension
%   than N, but in that case the result will not necessarily be meaningful.
%   In particular the "barycentric coordinates" returned may not add up to
%   1.
%
%   To find barycentric coordinates of a point on a triangle in 3D space,
%   use baryCoords.
%
%   To find barycentric coordinates of a point on a line in 3D space,
%   use baryCoords2.

    bc = [v ones(size(v,1),1)]/[ vxs, ones(size(vxs,1),1) ];
end
