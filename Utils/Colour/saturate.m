function c = saturate( s, c )
    if s < 0
        c = desaturate( -s, c );
    else
        if s > 1, s = 1; end
        mx = max(c,[],2);
        mn = min(c,[],2);
        if mn < mx
            c = mx - (mx - c)*((mx-(1-s)*mn)/(mx-mn));
        end
    end
end
