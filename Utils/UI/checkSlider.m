function ok = checkSlider( h )
    ok = false;
    v = get( h, 'Value' );
    mn = get( h, 'Min' );
    mx = get( h, 'Max' );
    if v < mn
        h
        v
        mn
        mx
        error('checkSlider: value less than Min.\n' );
    elseif v > mx
        h
        v
        mn
        mx
        error('checkSlider: value greater than Max.\n' );
    else
        ok = true;
    end
end
