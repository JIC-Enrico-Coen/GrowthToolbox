function cellStuff = vertexToCell( mesh, vertexStuff )
%cellStuff = vertexToCell( mesh, vertexStuff )
%   Convert a quantity defined per vertex to a quantity defined per cell.
%   The cell value is the average of all the vertex values for vertexes
%   belonging to the cell.

    vxsPerCell = size( mesh.tricellvxs, 2 );
    cellStuff = sum( vertexStuff( mesh.tricellvxs ), 2 )/vxsPerCell;
end
