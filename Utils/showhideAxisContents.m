function showhideAxisContents( ax, show )
    c = get( ax, 'Children' );
    onoff = boolchar( show, 'on', 'off' );
    set( c, 'Visible', onoff );
    if onoff
        set( ax, 'Visible', 'on' );
    end
end
