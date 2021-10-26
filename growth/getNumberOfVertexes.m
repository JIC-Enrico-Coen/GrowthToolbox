function num = getNumberOfVertexes( m )
%num = getNumberOfVertexes( m )
%   For volumetric meshes, return the number of vertexes.
%   Otherwise return the number of rows of m.nodes.
%
%   See also getTotalNumberOfVertexes.

    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        num = size( m.FEnodes, 1 );
    else
        num = size( m.nodes, 1 );
    end
end
