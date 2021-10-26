function gc = meshBaryToGlobalCoords( m, cells, bcs )
    gc = baryToGlobalCoords( cells, bcs, m.nodes, m.tricellvxs );
end
