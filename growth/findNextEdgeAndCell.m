function [nextEdge,nextCell] = findNextEdgeAndCell( m, curCell, curEdge, ni )
    cni = find( m.tricellvxs( curCell, : )==ni );
    cei = find( m.celledges( curCell, : )==curEdge );
    foo = [ [0 3 2]; [3 0 1]; [2 1 0] ];
    ncei = foo(cni,cei);
    nextEdge = m.celledges(curCell,ncei);
    nextCell = m.edgecells(nextEdge,2);
end

