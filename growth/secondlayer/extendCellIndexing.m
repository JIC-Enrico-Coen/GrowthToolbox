function secondlayer = extendCellIndexing( secondlayer, numnewcells, numnewedges, numnewvxs )
%m = extendCellIndexing( m, numnewcells, numnewedges, numnewvxs )
%   The given numbers of new biological cells, edges, and vertexes have
%   been added.  Extend all of the arrays holding information about cells,
%   edges, and vertexes, to include the new ones.

    if nargin==1
        numnewcells = max( length( secondlayer.cells ) - length( secondlayer.celldata.genindex ), 0 );
        numnewedges = max( size( secondlayer.edges, 1 ) - length( secondlayer.edgedata.genindex ), 0 );
        numnewvxs = max( size( secondlayer.cell3dcoords, 1 ) - length( secondlayer.vxdata.genindex ), 0 );
    end
    secondlayer.celldata = extenddata( secondlayer.celldata, numnewcells );
    secondlayer.edgedata = extenddata( secondlayer.edgedata, numnewedges );
    secondlayer.vxdata = extenddata( secondlayer.vxdata, numnewvxs );
end

function d = extenddata( d, n )
    if n>0
        d.genmaxindex = max(d.genmaxindex,0);
        newi = ((d.genmaxindex+1) : (d.genmaxindex+n))';
        d.genindex = [ d.genindex; newi ];
        d.genmaxindex = d.genmaxindex + n;
        d.parent( newi, : ) = zeros(n,size(d.parent,2));
        d.values( newi, : ) = zeros(n,size(d.values,2));
    end
end
