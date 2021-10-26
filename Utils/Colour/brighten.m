function c = brighten( b, c )
    if b < 0
        c = darken( -b, c );
    else
        if b > 1, b = 1; end
        m = max( c, [], 2 );
        newm = b + m*(1-b);
        c = c*(newm/m); 
    end
end
