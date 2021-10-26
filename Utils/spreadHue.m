function h = spreadHue( h, alph )
%h = spreadHue( h, alph )
%   This takes a value of hue in the range 0..1 and attempts to map it to
%   actual hue in a manner that better matches psychological distance, by
%   spreading apart the green/blue part of the colour wheel.  ALPH is a
%   parameter specifying the amount of spreading out.  0.2 is about right.

    fh = floor(h);
    h = h - fh;
    lo = h < 1/3;
    hi = h > 2/3;
    mid = ~(lo | hi);
    h(lo) = h(lo)*(1-alph);
    h(hi) = 1 - (1-h(hi))*(1-alph);
    h(mid) = 0.5 + (h(mid)-0.5)*(1+2*alph);
    h = h + fh;
end

