function perMembrane = VVconvertCellToMembrane( vvlayer, perCell )
%perMembrane = VVconvertCellToMembrane( vvlayer, perCell )
%   Given a value defined per cell, convert it to a value per membrane
%   vertex, by replicating the value for each cell onto all of its membrane
%   vertexes.

    perMembrane = zeros( size(vvlayer.edgeCM,1), 1 );
    perMembrane(vvlayer.edgeCM(:,2)) = perCell(vvlayer.edgeCM(:,1));
end
