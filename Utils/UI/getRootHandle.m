function r = getRootHandle( h )
    r = h;
    while true
        r1 = get(r,'Parent');
        if r1==0, return; end
        r = r1;
    end
end

