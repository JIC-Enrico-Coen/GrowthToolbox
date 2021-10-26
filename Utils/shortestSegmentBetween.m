function b = shortestSegmentBetween( n, i1, i2 )
%b = segmentBetween( n, i1, i2 )
%   Return the segment of 1:n that lies between index
%   i1 and i2, including i1 but not i2.  The segment will proceed downwards
%   or upwards, whichever gives the shortest result, and going round the
%   end of the array if necessary.  If i2==i1, the result is empty.
%
%   i1 and i2 are reduced mod n to lie within the bounds of 1:n.

    i1 = mod((i1-1),n) + 1;
    i2 = mod((i2-1),n) + 1;
    if i1==i2
        b = [];
    elseif i2 < i1
        len21 = i1 - i2;
        len12 = n - len21;
        if len12 <= len21
            b = [ i1:n, 1:(i2-1) ];
        else
            b = (i1-1):-1:i2;
        end
    else
        len12 = i2 - i1;
        len21 = n - len12;
        if len12 <= len21
            b = i1:(i2-1);
        else
            b = [ (i1-1):-1:1, n:-1:i2 ];
        end
    end
end
