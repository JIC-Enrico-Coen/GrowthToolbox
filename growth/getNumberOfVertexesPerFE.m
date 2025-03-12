function n = getNumberOfVertexesPerFE( m )
    if isVolumetricMesh( m )
        n = size( m.FEsets(1).fevxs, 2 );
    else
        n = size( m.tricellvxs, 2 );
    end
end
