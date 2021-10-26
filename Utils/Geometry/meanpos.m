function m = meanpos( nodes, tricellvxs, values )
%m = meanpos( nodes, triangles, values )
%   NODEs is an N*3 array, containing the vertex positions of a mesh.
%   TRIANGLES is an M*3 array of triples of node indexes, defining the
%   triangles of the mesh.
%   VALUES is an N*1 array of values defined at each vertex.
%   Consider VALUES to define the distribution of concentration os a
%   substance over the mesh, linearly interpolated over every triangle.
%   The result will be the centroid of that distribution.

    total = sum( values( tricellvxs(:) ) );
    trianglevertexes = reshape( nodes( tricellvxs', : ), 3, [], 3 );
    % Indexes are triangle, vertex, coordinate.
    trianglevalues = repmat( values( tricellvxs' ), [1, 1, 3] );
    m = permute( sum( sum( trianglevertexes .* trianglevalues, 2 ), 1 ), [1, 3, 2] )/total;
end
