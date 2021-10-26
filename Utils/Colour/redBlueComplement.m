function c = redBlueComplement( c, mode )
%c = redBlueComplement( c )
%   Compute a modified version of the colour complement of c (an N*3 matrix
%   of RGB values).  If 'mode' is 'redblue' then red and blue
%   are opposites, as are green and magenta.  If 'mode is 'redgreen', red
%   and green are opposites, as are orange and blue, and yellow and
%   magenta.  If mode is 'inverthue', the standard inversion of hue is
%   performed, i.e. red <-> cyan, green <-> magenta, and blue <-> yellow.
%   These three modes all leave the saturation and value unchanged.  In
%   particular, all grays from white to black are invariant.
%
%   Otherwise (the default), each component of c is inverted.  This
%   transforms hue in the same way as 'inverthue', but also inverts the
%   gray scale, and may change the saturation.

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
