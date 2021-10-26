function r = randInFEMcells( m, cellIndexes, n )
%r = randInFEMcells( m, cellIndexes, n )
%   Select n random points from within the given FEM cells.

    if isempty(cellIndexes)
        cellIndexes = 1:size(m.tricellvxs,1);
    end
    cellAreas = m.cellareas( cellIndexes );
  % cellAreas = ones( 1, length(cellIndexes) );
    [cells,bcs] = randInTriangles( cellAreas, n );
    r = meshBaryToGlobalCoords( m, cellIndexes(cells), bcs );
end
