function cellFactor = ConvertTissueToCellFactor( m, tissueFactor )
%cellFactor = ConvertTissueToCellFactor( m, tissueFactor )
%   Convert a tissue quantity to a per-cell quantity.
%   The tissue quantity can be defined per vertex or per element.
%   This procedure determines which by looking at the length of
%   tissueFactor.  The only triangular mesh with the same number of
%   elements as vertexes is the tetrahedron, which can safely be assumed to
%   never be used.  For volumetric meshes, there are a few more examples of
%   this, but bulk tissue containing many elements in every direction will
%   generally have more elements than vertexes.  In case of ambiguity, the
%   value will be interpreted as per-vertex.

    isPerVertex = size( tissueFactor, 1 )==getNumberOfVertexes(m);
    if isPerVertex
        cellFactor = perFEVertexToPerCell( m, perFEvertex );
    else
        cellFactor = perFEToPerCell( m, perFEvertex );
    end
end
