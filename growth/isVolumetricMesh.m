function is = isVolumetricMesh( m )
    is = usesNewFEs( m ) && ~m.globalProps.hybridMesh;
end
