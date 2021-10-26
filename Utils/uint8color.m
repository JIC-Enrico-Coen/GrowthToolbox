function uc = uint8color( c )
    uc = min( max( uint8(c*255), 0 ), 255 );
end
