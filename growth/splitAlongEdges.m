function [m,splitdata] = splitAlongEdges( m, eis )
%m = splitAlongEdges( m, eis )
%   Split every triangle containing any of the edges in eis into four.

    splitedgemap = false(1,size(m.edgeends,1));
    splitedgemap(eis) = true;
    splitcellmap = any( splitedgemap( m.celledges ), 2 );
    splitedges = unique( reshape( m.celledges( splitcellmap, : ), 1, [] ) );
    [m,splitdata] = splitalledges( m, splitedges );
end
