function elements = elementsFromEdgeMap( m, edgemap, mode )
%elements = elementsFromEdgeMap( m, edgemap, mode )
%   M is a mesh.  EDGE is a boolean map of edges or an array of edge indexes.
%   If MODE is 'all', find every finite element for which every edge is
%   in the set of nodes; if 'any', every finite element with at least one
%   edge in the set.
%   The set of elements is returned as a boolean map.  If you also need an
%   array of indexes, apply FIND to it.  If you only need an array of
%   indexes, call elementMapFromEdgeMap( m, nodes, mode );
%
%   See also: elementMapFromEdgeMap

    if nargin < 3
        elements = find( elementMapFromEdgeMap( m, edgemap ) );
    else
        elements = find( elementMapFromEdgeMap( m, edgemap, mode ) );
    end
end
