function vis = neighbourVxs( m, vi )
%vis = neighbourVxs( m, vi )
%   Find the vertexes that are the neighbours of vertex vi.

    if length(vi)==1
        nce = m.nodecelledges{vi};
        ee = m.edgeends( nce(1,:), : );
        vis = ee( ee ~= vi );
    else
        vmap = false( size(m.nodes,1), 1 );
        for i=1:length(vi)
            nce = m.nodecelledges{vi(i)};
            ee = m.edgeends( nce(1,:), : );
            vmap( ee( ee ~= vi(i) ) ) = true;
        end
        vis = find(vmap);
    end
end
