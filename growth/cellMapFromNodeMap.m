function cellmap = cellMapFromNodeMap( m, nodemap, mode )
%cellmap = cellmapfromnodes( m, nodemap, mode )
%   M is a mesh.  NODEMAP is an array of node indexes.
%   If MODE is 'all', find every finite element for which every vertex is
%   in the set of nodes; if 'any', every finite element with at least one
%   vertex in the set.
%   The set of cells is returned as a boolean map.  If you also need an
%   array of indexes, apply FIND to it.  If you only need an array of
%   indexes, call cellListFromNodeMap( m, nodes, mode );
%
%   See also: cellListFromNodeMap

    if nargin < 3
        requireall = true;
    else
        requireall = strcmp( mode, 'all' );
    end
    if isVolumetricMesh(m)
        fevxs = m.FEsets(1).fevxs;
    else
        fevxs = m.tricellvxs;
    end
    if requireall
        cellmap = all( nodemap(fevxs), 2 );
    else
        cellmap = any( nodemap(fevxs), 2 );
    end
end
