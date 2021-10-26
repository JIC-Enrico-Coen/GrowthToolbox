function m = addquad( m, i, j, k, l )
%m = addquad( m, i, j, k, l )
% m contains only m.nodes and m.tricellvxs.  Add two cells to m.tricellvxs,
% which tringulate the quadrilateral i j k l.

    numcells = size( m.tricellvxs, 1 );
    m.tricellvxs( [numcells, numcells+1], : ) =  [ [ i, j, k ]; [ j, k, l ] ];
end
