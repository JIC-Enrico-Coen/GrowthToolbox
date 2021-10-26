function perFEvx = perCellToperFEVertex2( m, perCell )
%perFEvx = perCellToperFEVertex2( m, perCell )
%   Convert a value per biological cell to a value per finite element
%   vertex.
%
%   This only applies to foliate meshes having a biological layer.  Other
%   meshes return a value that is everywhere zero.
%
%   This works by finding for each vertex the cell it lies in (or the
%   nearest cell if it does not lie in any), and taking the value for that
%   cell.
%
%   This does not work well when the cells are generally smaller than the
%   FEs, because many cells may then contain no FE vertexes and hence will
%   be ignored in the computation of the per-FE-vertex value.
%
%   perCellToperFEVertex uses a different algorithm to perform the
%   conversion, and may be generally preferred to this procedure.
%
%   See also: perCellToperFEVertex, perCellToperFE.

    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        perFEvx = zeros( getNumberOfVertexes(m), 1 );
        return;
    end
    
    cells = findCellForPoint( m, m.nodes );
    perFEvx = perCell( cells );
end

