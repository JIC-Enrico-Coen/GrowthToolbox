function announceview( h, az, el, roll )
    if hashandle( h, 'azimuthtext' )
        set( h.azimuthtext, 'String', sprintf( 'az:%.2f', az ) );
    end
    if hashandle( h, 'elevationtext' )
        set( h.elevationtext, 'String', sprintf( 'el:%.2f', el ) );
    end
    if hashandle( h, 'rolltext' )
        set( h.rolltext, 'String', sprintf( 'ro:%.2f', roll ) );
    end
    if hashandle( h, 'scalebar' )
        setscalebarsize( h );
    end
end
