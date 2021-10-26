function perFEvertex = ConvertCellToTissueFactor( m, perCell )
%perFEvertex = ConvertCellToTissueFactor( m, perCell )
%   Convert a value per biological cell to a value per finite element
%   vertex.
%
%   This only applies to foliate meshes having a biological layer.  Other
%   meshes return a value that is everywhere zero.
%
%   This works by first converting the per-cell value to a per-cell-vertex
%   value. Then for each cellular vertex we find which FE it lies in, and
%   its barycentric coordinates there.  Then for each vertex of the finite
%   element layer, we take a weighted average of the cell vertex values for
%   every cell vertex lying in any FE that the FE vertex belongs to.
%
%   This may leave some finite element vertex values undetermined, because
%   no cell vertex lies within any FE that the FE vertex belongs to.  For
%   these vertexes, we find the cell that they lie in (or the nearest cell,
%   it they do not lie in any) and use the cellular value for that cell.
%
%   perCellToperFEVertex2 does the same thing, but by a different (and
%   possibly inferior) algorithm.
%
%   See also: perCellToperFEVertex2, perCellToperFE.

    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        perFEvertex = zeros( getNumberOfVertexes(m), 1 );
        return;
    end
    
    perCellvertex = perCellToPerCellVertex( m, perCell );
    
    numFEvxs = getNumberOfVertexes(m);
    perFEvertex = zeros( numFEvxs, 1 );
    numPerFEvx = zeros( numFEvxs, 1 );
    for i=1:length(m.secondlayer.vxFEMcell)
        fei = m.secondlayer.vxFEMcell(i);
        bcs = m.secondlayer.vxBaryCoords(i,:)';
        fevxsi = m.tricellvxs(fei,:);
        perFEvertex(fevxsi) = perFEvertex(fevxsi) + perCellvertex(i)*bcs;
        numPerFEvx(fevxsi) = numPerFEvx(fevxsi) + bcs;
    end
    perFEvertex = perFEvertex./numPerFEvx;
    
    missingFEvxs = find(numPerFEvx==0);
    if ~isempty(missingFEvxs)
        cells = findCellForPoint( m, m.nodes(missingFEvxs,:) );
        perFEvertex(missingFEvxs) = perCell( cells );
    end
    
    xxxx = 1;
end

