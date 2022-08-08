function n = getNumberOfVolVertexes( m )
    if hasVolumetricCells( m )
        n = size( m.volcells.vxs3d, 1 );
    elseif isVolumetricCells( m )
        n = size( m.vxs3d, 1 );
    else
        n = 0;
    end
end