function n = windingNumber( vs )
    numpts = length(vs);
    n = 0;
    if numpts <= 2, return; end
    v = vs(numpts);
    for i=1:numpts
        d = vs(i) - v;
        if d > 0.5
            d = d-1;
        elseif d < -0.5
            d = d+1;
        end
        n = n+d;
        v = vs(i);
    end
    n = round(n);
end
