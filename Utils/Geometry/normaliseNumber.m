function a = normaliseNumber( a, lo, hi, lowerClosed )
%a = normaliseNumber( a, lo, hi, lowerClosed )
%   An integer multiple of HI-LO  is added to A as necessary to make
%   it fall in the range [LO..HI].  If lowerClosed is true
%   (the default), then the interval is [LO..HI), otherwise
%   (LO..HI].
%   LOWERCLOSED defaults to TRUE.
%   HI defaults to LO+1.
%   LO defaults to 0.
%   If LO==HI, every element of A is set to LO.
%   If LO > HI, LO and HI are swapped and LOWERCLOSED is negated.

    if nargin < 2
        lo = 0;
    end
    if nargin < 3
        hi = lo+1;
    end
    if nargin < 4
        lowerClosed = true;
    end
    if lo==hi
        a(:) = lo;
        return;
    end
    if hi < lo
        temp = hi;
        hi = lo;
        lo = temp;
        lowerClosed = ~lowerClosed;
    end
    range = double(hi-lo);
    for i=1:numel(a)
        b = a(i);
        if b==lo
            if ~lowerClosed
                b = hi;
            end
        elseif b==hi
            if lowerClosed
                b = lo;
            end
        elseif b < lo
            b = b + floor( (hi-b)/range )*range;
        elseif b > hi
            b = b - floor( (b-lo)/range )*range;
        end
        a(i) = b;
    end
end
