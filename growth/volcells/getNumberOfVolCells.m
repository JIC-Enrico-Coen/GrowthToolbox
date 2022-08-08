function n = getNumberOfVolCells( m )
    if hasVolumetricCells( m )
        n = size( m.volcells.polyfaces, 1 );
    elseif isVolumetricCells( m )
        n = size( m.polyfaces, 1 );
    else
        n = 0;
    end
end