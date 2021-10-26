function sl = joinCellLayers( sl1, sl2 )
    sl2.cellvxs = sl2.cellvxs + size(sl1.pts,1);
    d = size(sl1.cellvxs,2) - size(sl2.cellvxs,2);
    if d < 0
        sl1.cellvxs = [ sl1.cellvxs, nan( size(sl1.cellvxs,1), -d ) ];
    elseif d > 0
        sl2.cellvxs = [ sl2.cellvxs, nan( size(sl2.cellvxs,1), d ) ];
    end
    sl = struct( 'pts', [ sl1.pts; sl2.pts ], 'cellvxs', [sl1.cellvxs; sl2.cellvxs ] );
end
