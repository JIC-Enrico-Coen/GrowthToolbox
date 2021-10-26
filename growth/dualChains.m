function chains = dualChains( m, eis )
    if islogical(eis)
        eis = find(eis);
    end
    chains = emptystructarray( 'vxs', 'edges', 'faces', 'fes' );
    if isempty(eis)
        return;
    end
    numedges = size( m.FEconnectivity.edgeends, 1 );
    edgefes = invertIndexArray( m.FEconnectivity.feedges, numedges, 'cell' );
    for i=1:length(eis)
        ei = eis(i);
        efes = edgefes{ei};
        efaces = m.FEconnectivity.edgefaces(ei,:);
        efaces = efaces(efaces>0);
        % For each element in efes, find the opposite edge.
        eiopps = zeros(1,length(efes));
        for j=1:length(efes)
            fe = efes(j);
            fei = find( m.FEconnectivity.feedges(fe,:)==ei, 1 );
            feiopp = 1-fei;
            eiopps(j) = efes(feiopp);
        end
        chains(i) = struct( 'vxs', 'edges', 'faces', 'fes', efes );
    end
end
