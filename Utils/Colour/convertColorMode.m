function color = convertColorMode( color, desiredcolortype )
%color = convertColorMode( color, desiredcolortype )
%   Convert a color or image of any numeric type into the given numeric
%   type.  The input color is an array of any shape, of type double,
%   single, uint8, uint16, uint32, int8, int16, int32, or char.
%   desiredcolortype is a string naming any of those types except char.
%
%   This procedure is agnostic about the interpretation of the colour data
%   and can validly be applied to RGB, RGBA, HSV, etc.  It simply maps
%   between the range 0..1 of floating point numbers and the full ranges
%   of the various integer data types.  Signed integer values are converted
%   to unsigned, e.g. converting int8([0 -1]) to uint8 gives [0 255].
%
%   If color has type char, it is assumed to be an array of standard Matlab
%   single-character color names, in which case the corresponding RGB
%   triplet of the requested numeric type is returned. Unrecognised
%   characters are mapped to black. The result has size [ size(color), 3 ].
%
%   If desiredcolortype or the type of color is not recognised, then no
%   conversion is performed.

    if isa( color, desiredcolortype )
        % Nothing to do.
        return;
    end
    addsign = ~isempty( regexp( desiredcolortype, '^int', 'once' ) );
    if addsign
        desiredcolortype = ['u' desiredcolortype];
    end
    givencolortype = class(color);
    switch givencolortype
        case 'char'
            sz = size(color);
            color = color(:);
            result = zeros( length(color), 3 );
            for i=1:length(color)
                switch color(i)
                    case { 'r', 'red' }
                        result(i,:) = [1 0 0];
                    case { 'g', 'green' }
                        result(i,:) = [0 1 0];
                    case { 'b', 'blue' }
                        result(i,:) = [0 0 1];
                    case { 'c', 'cyan' }
                        result(i,:) = [0 1 1];
                    case { 'm', 'magenta' }
                        result(i,:) = [1 0 1];
                    case { 'y', 'yellow' }
                        result(i,:) = [1 1 0];
                    case { 'o', 'orange' }
                        result(i,:) = [1 0.5 0];
                    case { 'w', 'white' }
                        result(i,:) = [1 1 1];
%                     case { 'k', 'black' }
%                         result(i,:) = [0 0 0];
%                     otherwise
%                         result(i,:) = [0 0 0];
                end
            end
            color = reshape( result, [ sz, 3 ] );
            color = convertColorMode( color, desiredcolortype );
        case 'double'
            switch desiredcolortype
                case 'single'
                    color = single(color);
                case 'uint8'
                    color = uint8( min( max( floor( color*256 ), 0 ), 255 ) );
                case 'uint16'
                    color = uint16( min( max( floor( color*65536 ), 0 ), 65535 ) );
                case 'uint32'
                    color = uint32( min( max( floor( color*4294967296 ), 0 ), 4294967295 ) );
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'single'
            color = double(color);
            switch desiredcolortype
                case 'uint8'
                    color = uint8( min( max( floor( color*256 ), 0 ), 255 ) );
                case 'uint16'
                    color = uint16( min( max( floor( color*65536 ), 0 ), 65535 ) );
                case 'uint32'
                    color = uint32( min( max( floor( color*4294967296 ), 0 ), 4294967295 ) );
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'uint8'
%             color = double(color)/255;
            switch desiredcolortype
                case 'single'
                    color = single(color)/255;
                case 'double'
                    color = double(color)/255;
                case 'uint16'
                    color = uint16(color) * 257;  % (2^8 + 1)
                case 'uint32'
                    color = uint32(color) * 16843009;  % ((2^8 + 1)*(2^16 + 1))
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'uint16'
            switch desiredcolortype
                case 'single'
                    color = single(color)/65535;
                case 'double'
                    color = double(color)/65535;
                case 'uint8'
                    color = uint8(double(color)/257);
                case 'uint32'
                    color = uint32(color) * 65537;
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'uint32'
            switch desiredcolortype
                case 'single'
                    color = single(color)/4294967295;
                case 'double'
                    color = double(color)/4294967295;
                case 'uint8'
                    color = uint8(double(color)/16843009);  % 16843009 = 4294967295/255
                case 'uint16'
                    color = uint8(double(color)/65537);
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'int8'
            color = convertColorMode( unsign8(color), desiredcolortype );
        case 'int16'
            color = convertColorMode( unsign16(color), desiredcolortype );
        case 'int32'
            color = convertColorMode( unsign32(color), desiredcolortype );
        otherwise
            fprintf( 1, '%s: Unrecognized input image type %s.\n', mfilename(), givencolortype );
    end
    
    if addsign
        switch desiredcolortype
            case 'uint8'
                color = addsign8( color );
            case 'uint16'
                color = addsign16( color );
            case 'uint32'
                color = addsign32( color );
        end
    end
end

function w = addsign8( v )
    w = int8(v);
    w(v>=128) = int8( v(v>=128)-128 ) - 128;
end

function w = addsign16( v )
    w = int16(v);
    w(v>=32768) = int16( v(v>=32768)-32768 ) - 32768;
end

function w = addsign32( v )
    w = int32(v);
    w(v>=2147483648) = int32( v(v>=2147483648)-2147483648 ) - 2147483648;
end

function w = unsign8( v )
    w = uint8(v);
    w(v<0) = double(v(v<0)) + 256;
end

function w = unsign16( v )
    w = uint16(v);
    w(v<0) = double(v(v<0)) + 65536;
end

function w = unsign32( v )
    w = uint32(v);
    w(v<0) = double(v(v<0)) + 65536^2;
end
