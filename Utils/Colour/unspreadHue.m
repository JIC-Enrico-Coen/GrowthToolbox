function h = unspreadHue( h, alph )
%h = unspreadHue( h, alph )
%   The inverse of h = spreadHue( h, alph )

    fh = floor(h);
    h = h - fh;
    lo = h < (1-alph)/3;
    hi = h > 1 - (1-alph)/3;
    mid = ~(lo | hi);
    h(lo) = h(lo)/(1-alph);
    h(hi) = 1 - (1-h(hi))/(1-alph);
    h(mid) = 0.5 + (h(mid)-0.5)/(1+2*alph);
    h = h + fh;
end

