function perFEvx = perCellToperFEVertex( m, perCell )
%perFEvx = perCellToperFEVertex( m, perCell )
%   Deprecated: use ConvertCellToTissueFactor instead.

    perFEvx = CellToFEvertex( m, perCell );
end

