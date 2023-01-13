function rgbdark = darkenColor( rgb, darkening )
%rgbdark = darkenColor( rgb, darkening )
%   Darken the color by the given amount. If DARKENING = 0, then the color
%   is unchanged. If 1, the resulting color is black. Intermediate values
%   linearly interpolate.

    ic = iscell( rgb );
    if ic
        sz = size(rgb);
        rgb = cell2mat( rgb(:) );
    end
    
    rgbdark = rgb .* (1 - darkening);
    
    if ic
        rgbdark = num2cell( rgbdark, 2 );
        rgbdark = reshape( rgbdark, sz );
    end
end
