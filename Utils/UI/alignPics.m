function alignPics( m )
    p1 = get( m.pictures(1), 'Position' );
    p2 = get( m.pictures(2), 'Position' );
    p2a = p1 + [-500 0 0 0];
    if any( p2 ~= p2a )
        set( m.pictures(2), 'Position', p2a );
    end
end

