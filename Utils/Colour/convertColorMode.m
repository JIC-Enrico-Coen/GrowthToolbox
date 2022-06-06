function color = convertColorMode( color, desiredcolortype )
%color = convertColorMode( color, desiredcolortype )
%   Convert a color or image of any numeric type into the given numeric
%   type.  The input color is an array of any shape, of type double,
%   single, uint8, uint16, uint32, uint64, int8, int16, int32, int64, char,
%   or string. desiredcolortype is a string naming any of those types
%   except char or string.
%
%   This procedure is agnostic about the interpretation of the colour data
%   and can validly be applied to RGB, RGBA, HSV, etc.  It simply maps
%   between the range 0..1 of floating point numbers and the full ranges
%   of the various integer data types. Conversion between signed and
%   unsigned integers preserves their twos-complement bit patterns. For
%   example, black and white are [000] and [255 255 255] for uint8, and
%   [0 0 0] and [-1 -1 -1] for int8. Whether this is the right thing to do
%   is arguable, but it is more arguable that signed integers should not be
%   used for image data at all.
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
    
    % To convert to a signed integer type, we first convert to the unsigned
    % type, then convert to signed.
    addsign = ~isempty( regexp( desiredcolortype, '^int', 'once' ) );
    if addsign
        desiredcolortype = ['u' desiredcolortype];
    end
    
    givencolortype = class(color);
    switch givencolortype
        case {'char','string'}
            if isstring(color)
                color = char(color);
            end
            sz = size(color);
            color = color(:);
            result = zeros( numel(color), 3 );
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
                case 'uint64'
                    color = uint32( min( max( floor( color*2^64 ), 0 ), 2^64-1 ) );
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
                case 'uint64'
                    color = uint32( min( max( floor( color*2^64 ), 0 ), 2^64-1 ) );
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
                    color = uint16(color) * 257;  % 2^8 + 1
                case 'uint32'
                    color = uint32(color) * 16843009;  % (2^8 + 1)*(2^16 + 1)
                case 'uint64'
                    color = uint64(color) * 72340172838076672;  % (2^8 + 1)*(2^16 + 1)*(2^32 + 1)
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
                    color = uint32(color) * 65537;  % 2^16 + 1
                case 'uint64'
                    color = uint64(color) * 281479271743489;  % (2^16 + 1)*(2^32 + 1)
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
                    color = uint8(double(color)/16843009);  % (2^32-1)/(2^8-1)
                case 'uint16'
                    color = uint16(double(color)/65537);  % 2^16 + 1
                case 'uint64'
                    color = uint32(color) * 4294967297;  % 2^32 + 1
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'uint64'
            switch desiredcolortype
                case 'single'
                    color = single(double(color)/(2^64-1));
                case 'double'
                    color = double(color)/(2^64-1);
                case 'uint8'
                    color = uint8(double(color)/72340172838076672);  % (2^64-1)/(2^8-1)
                case 'uint16'
                    color = uint16(double(color)/281479271743489);  % (2^64-1)/(2^16-1)
                case 'uint32'
                    color = uint32(color) * 4294967297;  % 2^32+1
                otherwise
                    fprintf( 1, '%s: Unrecognized output image type %s.\n', mfilename(), desiredcolortype );
            end
        case 'int8'
            color = convertColorMode( unsign8(color), desiredcolortype );
        case 'int16'
            color = convertColorMode( unsign16(color), desiredcolortype );
        case 'int32'
            color = convertColorMode( unsign32(color), desiredcolortype );
        case 'int64'
            color = convertColorMode( unsign64(color), desiredcolortype );
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
            case 'uint64'
                color = addsign64( color );
        end
    end
end

function w = addsign8( v )
    correctionint = 2^7;
    w = int8(v);
    w(v>=correctionint) = int8( v(v>=correctionint)-correctionint ) - correctionint;
end

function w = addsign16( v )
    correctionint = 2^15;
    w = int16(v);
    w(v>=correctionint) = int16( v(v>=correctionint)-correctionint ) - correctionint;
end

function w = addsign32( v )
    correctionint = 2^31;
    w = int32(v);
    w(v>=correctionint) = int32( v(v>=correctionint)-correctionint ) - correctionint;
end

function w = addsign64( v )
    correctionint = 2^63;
    w = int64(v);
    w(v>=correctionint) = int64( v(v>=correctionint)-correctionint ) - correctionint;
end

function w = unsign8( v )
    correctionint = 2^8;
    w = uint8(v);
    w(v<0) = uint8( double(v(v<0)) + correctionint );
end

function w = unsign16( v )
    correctionint = 2^16;
    w = uint16(v);
    w(v<0) = uint16( double(v(v<0)) + correctionint );
end

function w = unsign32( v )
    correctionint = 2^32;
    w = uint32(v);
    w(v<0) = uint32( double(v(v<0)) + correctionint );
end

function w = unsign64( v )
    correctionint = 2^64;
    w = uint64(v);
    w(v<0) = uint64( double(v(v<0)) + correctionint );
end
