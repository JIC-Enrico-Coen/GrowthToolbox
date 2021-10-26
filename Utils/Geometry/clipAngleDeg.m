function a = clipAngleDeg( a, rangeStart )
    if nargin < 2
        rangeStart = -180;
    end
    a = a - rangeStart;
    neg = a < 0;
    a(neg) = -a(neg);
    a = a - floor(a/360)*360;
    flipagain = neg & (a > 0);
    a(flipagain) = 360 - a(flipagain);
    a = a + rangeStart;
end
