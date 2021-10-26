function cells = cellsFromEdgeMap( m, edgemap, mode )
%cells = cellsFromEdgeMap( m, edgemap, mode )
%   M is a mesh.  EDGE is a boolean map of edges or an array of edge indexes.
%   If MODE is 'all', find every finite element for which every edge is
%   in the set of nodes; if 'any', every finite element with at least one
%   edge in the set.
%   The set of cells is returned as a boolean map.  If you also need an
%   array of indexes, apply FIND to it.  If you only need an array of
%   indexes, call cellMapFromEdgeMap( m, nodes, mode );
%
%   See also: cellMapFromEdgeMap

    if nargin < 3
        cells = find( cellMapFromEdgeMap( m, edgemap ) );
    else
        cells = find( cellMapFromEdgeMap( m, edgemap, mode ) );
    end
end
