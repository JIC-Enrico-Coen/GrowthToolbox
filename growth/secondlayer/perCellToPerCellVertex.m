function perCellvertex = perCellToPerCellVertex( m, perCell )
%perCellvertex = perCellToPerCellVertex( m, perCell )
%   Convert a value specified per cell to one specified per cell vertex.
%   Each vertex gets the average of the values for the cells that it is a
%   vertex of.
%
%   DEPRECATED: renamed to CellToCellvertexFactor;

    perCellvertex = CellToCellvertex( m, perCell );
    return;
    
    perCellvertex = zeros( length(m.secondlayer.vxFEMcell), 1 );
    cellspervertex = zeros( length(m.secondlayer.vxFEMcell), 1 );
    for ci=1:length(m.secondlayer.cells)
        cellvxs = m.secondlayer.cells(ci).vxs;
        perCellvertex(cellvxs) = perCellvertex(cellvxs) + perCell(ci);
        cellspervertex(cellvxs) = cellspervertex(cellvxs) + 1;
    end
    perCellvertex = perCellvertex./cellspervertex;
    perCellvertex(~isfinite(perCellvertex)) = 0;
end
