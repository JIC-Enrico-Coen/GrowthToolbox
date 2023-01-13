function c = desaturate( s, c )
    if s < 0
        c = saturate( -s, c );
    else
        if s > 1, s = 1; end
        mx = max( c, [], 2 );
%         mn = min( c, [], 2 );
        c = mx - (mx-c)*(1-s);
    end
end
