function cellmap = cellMapFromEdgeMap( m, edgemap, mode )
%cellmap = cellMapFromEdgeMap( m, edgemap, mode )
%   M is a mesh.  EDGE is a boolean map of edges or an array of edge indexes.
%   If MODE is 'all', find every finite element for which every edge is
%   in the set of nodes; if 'any', every finite element with at least one
%   edge in the set.
%   The set of cells is returned as a boolean map.  If you also need an
%   array of indexes, apply FIND to it.  If you only need an array of
%   indexes, call cellsFromEdgeMap( m, nodes, mode );
%
%   See also: cellsFromEdgeMap

    if nargin < 3
        requireall = true;
    else
        requireall = strcmp( mode, 'all' );
    end
    if requireall
        cellmap = all( edgemap(m.celledges), 2 );
    else
        cellmap = any( edgemap(m.celledges), 2 );
    end
end
