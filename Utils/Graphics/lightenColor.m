function rgblight = lightenColor( rgb, lightening )
%rgblight = lightenColor( rgb, lightening )
%   Lighten the color by the given amount. If LIGHTENING = 0, then the color
%   is unchanged. If 1, the resulting color is white. Intermediate values
%   linearly interpolate.

    ic = iscell( rgb );
    if ic
        sz = size(rgb);
        rgb = cell2mat( rgb(:) );
    end
    
    rgblight = 1 - (1 - rgb) .* (1 - lightening);
    
    if ic
        rgblight = num2cell( rgblight, 2 );
        rgblight = reshape( rgblight, sz );
    end
end
