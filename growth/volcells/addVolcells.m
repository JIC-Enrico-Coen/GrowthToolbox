function m = addVolcells( m, volcells )
    if ~isVolumetricCells( volcells )
        return;
    end
    
    [ ci, bc, bcerr, abserr, ishint ] = findFE( m, volcells.vxs3d );
    volcells.vxfe = ci;
    volcells.vxbc = bc;
    
    if hasVolumetricCells( m )
        m.volcells = unionVolCells( m.volcells, volcells );
    else
        m.volcells = volcells;
    end
end
