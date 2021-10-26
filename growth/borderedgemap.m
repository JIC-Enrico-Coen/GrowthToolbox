function edgemap = borderedgemap( m, cellmap )
%edgemap = borderedgemap( m, cellmap )
%   M is a mesh.  CELLMAP is a boolean map of cells.
%   All of the border edges of the set of cells are found, that
%   is, every edge which has one of the given cells on exactly one side.
%   The set of edges is returned as a boolean map.  If you need an array of
%   indexes, call borderedges( m, cellmap ).
%
%   See also: borderedges

    if nargin < 2
        cellmap = true(1, size(m.tricellvxs,1));
    end
    celledges = unique(m.celledges(cellmap,:));
    edgecells = m.edgecells(celledges,:);
    if isempty(edgecells)
        edgemap = false( size(m.edgeends,1), 1 );
    else
        edgemap1 = cellmap(edgecells(:,1));
        edgemap2 = edgecells(:,2) > 0;
        edgemap2(edgemap2) = cellmap( edgecells(edgemap2,2) );
        edgemap = edgemap1(:) ~= edgemap2(:);
    end
end
