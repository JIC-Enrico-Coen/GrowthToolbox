function m = upgradeVolumetricMesh( m )
    if ~isVolumetricMesh( m )
        return;
    end
    
    if ~isfield( m.FEconnectivity, 'fefaces' )
        m.FEconnectivity = connectivity3D( m );
    end
    
    if isT4mesh(m) && ~isfield( m.FEsets, 'fevolumes' )
        m = calcFEvolumes( m );
    end
    
    if hasSecondLayer( m ) && ~isfield( m.secondlayer, 'surfaceVertexes' )
        m.secondlayer.surfaceVertexes = true( length(m.secondlayer.vxFEMcell), 1 );
    end
end
