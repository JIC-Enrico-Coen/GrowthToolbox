function [m,numElided] = elideSmallEdges( m )
%     esqs = edgelengthsqs( m );
%     edges = find( esqs < 0.2^2 );

    edges = shortEdges( m, m.globalProps.maxFEratio, 'any' );
%     seledges = maxdisjointfaces( m.FEconnectivity.edgeends(edges,:) );
%     edges = edges(seledges);
    edges = nonContactEdges( m, edges );

    numElided = length(edges);
    if numElided > 0
        m = collapseT4edges( m, edges );
    end
end
