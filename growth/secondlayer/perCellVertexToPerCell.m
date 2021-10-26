function perCell = perCellVertexToPerCell( m, perCellvertex )
%perCell = perCellVertexToPerCell( m, perCellvertex )
%   Convert a value specified per cell vertex to one specified per cell.
%   Each cell gets the average of the values for the vertexes that belong
%   to it.

    numcells = length(m.secondlayer.cells);
    perCell = zeros( numcells, 1 );
    for ci=1:numcells
        secondlayer_vxs = m.secondlayer.cells(ci).vxs;
        perCell(ci) = sum( perCellvertex(secondlayer_vxs), 1 ) / length( secondlayer_vxs );
    end
end
