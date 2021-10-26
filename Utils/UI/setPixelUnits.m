function setPixelUnits( h )
    set( h, 'Units', 'pixels' );
    c = get( h, 'Children' );
    for i:c
        setPixelUnits( c(i) );
    end
end
