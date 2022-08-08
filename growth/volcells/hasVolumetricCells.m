function has = hasVolumetricCells( m )
    has = isfield( m, 'volcells' ) && isVolumetricCells( m.volcells );
end