function triang = bridgeEdgeLoops( vxs, e1, e2 )
%triang = bridgeEdgeLoops( vxs, e1, e2 )
%   e1 and e2 are lists of indexes into vxs, such that no vertex occurs
%   twice in e1 and e2 together.  e1 and e2 thus define disjoint polygons.
%   The result is a triangulation of a surface connecting the two polygons.
%   For two general polygons there is no such thing as "the" triangulation
%   or "the' surface conneting them.  Instead, this procedure tries to find
%   a reasonable triangulation, assuming that there is one.  It always
%   finds a triangulation, but if the input data are unreasonable, the
%   output should not be expected to be any better.
%
%   This is incomplete: even when there is a reasonable triangulation, this
%   procedure might happen to get started followiong the two edge loops in
%   opposite directions.  It should try both and choose the better one (for
%   some measure of quality).

    triang = [];
    if isempty(e1) || isempty(e2)
        return;
    end
    e1 = e1(:);
    e2 = e2(:);
    n1 = length(e1);
    n2 = length(e2);
    v1 = vxs(e1,:);
    v2 = vxs(e2,:);
    
    % 1.  Find the pair of vertexes of the respective polygons that are the
    % closest to each other.
    dsq = zeros(n1,n2);
    for i=1:n1
        for j=1:n2
            dsq(i,j) = sum( (v1(i,:)-v2(j,:)).^2 );
        end
    end
    [d,i] = min(dsq(:));
    vi1 = mod(i-1,n1)+1;
    vi2 = (i-vi1)/n1 + 1;
    
    e1 = e1([vi1:end 1:(vi1-1)]);
    e2 = e2([vi2:end 1:(vi2-1)]);
    dsq = dsq([vi1:end 1:(vi1-1)],[vi2:end 1:(vi2-1)]);
    vi1 = 1;
    vi2 = 1;
    triang = zeros(n1+n2,3);
    totaldsq = dsq(vi1,vi2);
    for ti=1:(n1+n2-1)
        vi1a = vi1+1;
        vi2a = vi2+1;
        if vi2a > n2
            d12a = Inf;
            vi2a = 1;
        else
            d12a = dsq(vi1,vi2a);
        end
        if vi1a > n1
            d1a2 = Inf;
            vi1a = 1;
        else
            d1a2 = dsq(vi1a,vi2);
        end
        if d12a < d1a2
            triang(ti,:) = [e1(vi1),e2(vi2a),e2(vi2)];
            vi2 = vi2a;
        else
            triang(ti,:) = [e1(vi1a),e2(vi2),e1(vi1)];
            vi1 = vi1a;
        end
        totaldsq = totaldsq + dsq(vi1,vi2);
    end
    if triang(n1+n2-1,1)==e1(1)
        triang(n1+n2,:) = [ e1(1),e2(1),triang(n1+n2-1,2) ];
    else
        triang(n1+n2,:) = [ e1(1),e2(1),triang(n1+n2-1,1) ];
    end
    triang
    totaldsq
end
