function c = oppositeColor( c, mode )
%c = oppositeColor( c, mode )
%   Compute a modified version of the colour complement of c (an N*3 matrix
%   of RGB values).
%
%   mode is one of the following:
%
%   'invertvalue' (the default):  The red, green, and blue channels are
%       inverted.  Thus red <-> cyan, green <-> magenta, blue <-> yellow,
%       and white <-> black.  Dark colors map to pale colors.
%
%   'inverthue':  The hue is inverted but saturation and value left
%       unchanged.  Thus red <-> cyan, green <-> magenta, blue <-> yellow,
%       but white, black, and all shades of grey are left unchanged.  Dark
%       colors map to dark, and pale to pale.
%
%   'redblue':   Like inverthue, but uses a transformation of hue that maps
%       red <-> blue, green <-> magenta.
%
%   'redgreen':  Like inverthue, but uses a transformation of hue that maps
%       red <-> green, orange <-> blue, yellow <-> magenta.

    if nargin < 2
        c = 1-c;
        return;
    end
    switch mode
        case 'redblue'
            c1 = rgb2hsv( c );
            hues = mod( floor( c1(:,1)*3 ), 3 ) + 1;
            a = [ 0.5, 0.5, 2 ];
            b = [ 2, 2, -1 ]/3;
            c1(:,1) = c1(:,1).*a(hues) + b(hues);
            c = hsv2rgb( c1 );
        case 'redgreen'
            c1 = rgb2hsv( c );
            hues = mod( floor( c1(:,1)*12 ), 12 ) + 1;
            a = [4; 2; 1; 1; 0.25; 0.25; 0.25; 0.25; 0.5; 0.5; 1; 1];
            b = [4; 6; 8; 8; -1; -1; -1; -1; -3; -3; -8; -8]/12;
            c1(:,1) = c1(:,1).*a(hues) + b(hues);
            c = hsv2rgb( c1 );
        case 'inverthue'
            c1 = rgb2hsv( c );
            c1(:,1) = mod( c1(:,1) + 0.5, 1 );
            c = hsv2rgb( c1 );
        case 'invertvalue'
            c = 1-c;
        otherwise
            c = 1-c;
    end
end
