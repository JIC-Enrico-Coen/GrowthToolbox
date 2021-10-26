function num = getTotalNumberOfVertexes( m )
%num = getTotalNumberOfVertexes( m )
%   For volumetric meshes, return the number of vertexes.
%   Otherwise return the number of rows of m.prismnodes.
%
%   See also getNumberOfVertexes.

    if isempty(m)
        num = 0;
    elseif usesNewFEs(m)
        num = size( m.FEnodes, 1 );
    else
        num = size( m.prismnodes, 1 );
    end
end
