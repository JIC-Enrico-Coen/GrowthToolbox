function [ve,vv] = findCellVxEdges( m )
% ve will be an N*3 array listing for every vertex the edges incident on
% it. there should never be more than 3. There can be 2, in which case the
% 3rd index will be 0.
% vv will list the vertexes at the other ends of those edges.

    ve1 = sortrows( [ int32(reshape(m.secondlayer.edges(:,[1 2]),[],1)), repmat( int32(1:getNumberOfCellEdges(m))', 2, 1 ) ] );
    [starts, ends] = runends( ve1(:,1) );
    if max( ends-starts ) > 2
        xxxx = 1;
    end
    ve = zeros( getNumberOfCellvertexes(m), max( 3, max( ends-starts ) + 1 ), 'int32' );
    vv = ve;
    for i=1:length(starts)
        s = starts(i);
        e = ends(i);
        n = e-s+1;
        v = ve1(s,1);
        ve(v,1:n) = ve1(s:e,2)';
        othervxs = reshape( m.secondlayer.edges(ve(v,1:n),[1 2])', 1, [] );
        othervxs = othervxs(othervxs ~= v);
        vv(v,1:n) = othervxs;
    end
end

