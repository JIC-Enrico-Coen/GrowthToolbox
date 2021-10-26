function nodes = findUnusedNodes( m )
    numtrivxs = size( m.nodes, 1 );
    cellsPerVertex = zeros( numtrivxs, 1,'int32' );
    numcells = size( m.celldata, 2 );
    numtrivxsPerCell = size( m.tricellvxs, 2 );
    for ci=1:numcells
        for vi=1:numtrivxsPerCell
            vx = m.tricellvxs(ci,vi);
            cellsPerVertex( vx ) = cellsPerVertex( vx ) + 1;
        end
    end
    nodes = find(cellsPerVertex==0);
end

