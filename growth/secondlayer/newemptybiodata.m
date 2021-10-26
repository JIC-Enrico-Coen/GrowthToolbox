function sl = newemptybiodata( sl, force )
%d = newemptybiodata( p )
%   Make a new empty set of indexing and value data for the cells,
%   edges, and vertexes.

    if nargin < 2
        force = false;
    end
    if force || ~isfield( sl, 'celldata' )
        numcells = length(sl.cells);
        sl.celldata = newemptyobjectdata( 1, numcells );
    end
    if force || ~isfield( sl, 'edgedata' )
        numedges = size(sl.edges,1);
        sl.edgedata = newemptyobjectdata( 2, numedges );
    end
    if force || ~isfield( sl, 'vxdata' )
        numvxs = size(sl.cell3dcoords,1);
        sl.vxdata = newemptyobjectdata( 3, numvxs );
    end
end

function d = newemptyobjectdata( parents, numitems )
    d.genindex = zeros(numitems,1);
    d.genmaxindex = 0;
    d.parent = zeros(numitems,parents);
    d.values = zeros(numitems,0);
end
