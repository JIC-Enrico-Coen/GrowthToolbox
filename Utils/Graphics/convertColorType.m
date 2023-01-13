function ct = convertColorType( c, t )

    global CHARCOLORS
    if isa(c,t)
        ct = c;
    else
        switch class(c)
            case 'int8'
                c = double( mod( int16(c), 255 ) )/255;
            case 'uint8'
                c = double( c )/255;
            case 'int16'
                c = double( mod( int32(c), 65535 ) )/65535;
            case 'uint16'
                c = double( c )/65535;
            case 'int32'
                c = double( mod( int64(c), 4294967295 ) )/4294967295;
            case 'uint32'
                c = double( c )/4294967295;
            case 'int64'
                c1 = double( c )/18446744073709551615;
                c1(c1<0) = c1(c1<0) + 1;
                c = c1;
            case 'uint64'
                c = double( c )/2147483647;
            case 'single'
                c = double(c);
            case 'char'
                c = lower(c(:)) - 'a' + 1;
                c(c<=0) = 1;
                c(c>26) = 26;
                if isempty( CHARCOLORS )
                    CHARCOLORS = ones(26,3);
                    CHARCOLORS('r'-'a'+1,:) = [1 0 0];
                    CHARCOLORS('g'-'a'+1,:) = [0 1 0];
                    CHARCOLORS('b'-'a'+1,:) = [0 0 1];
                    CHARCOLORS('c'-'a'+1,:) = [0 1 1];
                    CHARCOLORS('m'-'a'+1,:) = [1 0 1];
                    CHARCOLORS('y'-'a'+1,:) = [1 1 0];
                    CHARCOLORS('w'-'a'+1,:) = [1 1 1];
                    CHARCOLORS('k'-'a'+1,:) = [0 0 0];
                    CHARCOLORS('o'-'a'+1,:) = [1 0.5 0];
                end
                
                c = CHARCOLORS(c,:);
            case 'double'
                % Nothing.
            otherwise
                c = double(c);
        end
        
        switch t
            case 'int8'
                ct = int16( c*255 );
                ct(ct>=128) = ct(ct>=128) - 256;
                ct = int8( ct );
            case 'uint8'
                ct = uint8( c*255 );
            case 'int16'
                ct = int32( c*65535 );
                ct(ct>=32768) = ct(ct>=32768) - 65536;
                ct = int16( ct );
            case 'uint16'
                ct = uint8( c*65535 );
            case 'int32'
            case 'uint32'
                ct = uint32( c*4294967295 );
            case 'int64'
            case 'uint64'
                ct = uint64( c*18446744073709551615 );
            case 'single'
                ct = single( c );
            case 'double'
                ct = c;
            otherwise
                ct = c;
        end
    end
end
