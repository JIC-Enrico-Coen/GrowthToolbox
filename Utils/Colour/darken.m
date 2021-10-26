function c = darken( d, c )
    if d < 0
        c = brighten( -d, c );
    else
        if d > 1, d = 1; end
        c = c*d; 
    end
end
