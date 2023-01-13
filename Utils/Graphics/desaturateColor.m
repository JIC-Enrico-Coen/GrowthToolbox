function rgbdesat = desaturateColor( rgb, s )
    ic = iscell( rgb );
    if ic
        sz = size(rgb);
        rgb = cell2mat( rgb(:) );
    end
    
    if s < 0
        rgbdesat = saturate( -s, rgb );
    else
        if s > 1, s = 1; end
        mx = max( rgb, [], 2 );
%         mn = min( rgb, [], 2 );
        rgbdesat = mx - (mx-rgb)*(1-s);
    end
    
    if ic
        rgbdesat = num2cell( rgbdesat, 2 );
        rgbdesat = reshape( rgbdesat, sz );
    end
end
