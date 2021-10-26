function [vxs,edges] = makePolygon( mesh, cells, cellmap )
%vxs = makePolygon( mesh, cells )
%   Assuming that the given FEM elements form a connected region of the mesh
%   with no holes, list the vertexes and edges of the polygon that they form.
%   CELLS is the list of cell indexes.  CELLMAP is a bitmap thereof.

    if nargin < 3
        cellmap = zeros( 1, size( mesh.tricellvxs, 1 ) );
        cellmap(cells) = 1;
    end
    
    if isempty( cells )
        vxs = [];
        edges = [];
        return;
    end

    alledges = mesh.celledges( cells, : );
    alledgesmap = zeros( 1, size( mesh.edgeends, 1 ) );
    alledgesmap( alledges ) = 1;
    alledges = find( alledgesmap );
    polyedgesmap = zeros( size(alledgesmap) );
    for i=1:length(alledges)
        c = mesh.edgecells( alledges(i), : );
        if c(2)==0
            polyedgesmap(alledges(i)) = 1;
        elseif ~all( cellmap( c ) )
            polyedgesmap(alledges(i)) = 1;
        end
    end
    edges = find( polyedgesmap );
    unorderedvxs = mesh.edgeends( edges, : );
    [vxs,perm] = findCycle( unorderedvxs );
    edges = edges(perm);
end

        
