function elementmap = elementMapFromEdgeMap( m, edgemap, mode )
%elementmap = elementMapFromEdgeMap( m, edgemap, mode )
%   M is a mesh.  EDGE is a boolean map of edges or an array of edge indexes.
%   If MODE is 'all', find every finite element for which every edge is
%   in the set of nodes; if 'any', every finite element with at least one
%   edge in the set.
%   The set of elements is returned as a boolean map.  If you also need an
%   array of indexes, apply FIND to it.  If you only need an array of
%   indexes, call elementsFromEdgeMap( m, nodes, mode );
%
%   See also: elementsFromEdgeMap

    if nargin < 3
        requireall = true;
    else
        requireall = strcmp( mode, 'all' );
    end
    if requireall
        elementmap = all( edgemap(m.celledges), 2 );
    else
        elementmap = any( edgemap(m.celledges), 2 );
    end
end
