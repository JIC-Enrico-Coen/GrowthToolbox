function n = getNumberOfVolFaces( m )
    if hasVolumetricCells( m )
        n = size( m.volcells.facevxs, 1 );
    elseif isVolumetricCells( m )
        n = size( m.facevxs, 1 );
    else
        n = 0;
    end
end