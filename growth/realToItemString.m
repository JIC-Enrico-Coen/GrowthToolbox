function s = realToItemString( r )
    s = sprintf( '%.10f', r );
    s = realStringToItemString( s );
end
