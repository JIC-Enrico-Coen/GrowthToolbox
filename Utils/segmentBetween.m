function b = segmentBetween( a, i1, i2 )
%b = segmentBetween( a, i1, i2 )
%   Return the segment of the 1-dimensional array A that lies between index
%   i1 and i2, including i1 but not i2.  If i2 is less than i1 then the
%   segment should proceed from i1 to the end of A and continue from the
%   beginning.  If i2==i1, the result is empty.
%
%   i1 and i2 are reduced mod length(a) to lie within the bounds of A.

    i1 = mod((i1-1),length(a)) + 1;
    i2 = mod((i2-1),length(a)) + 1;
    if i2 < i1
        b = a( [ i1:end, 1:(i2-1) ] );
    else
        b = a( i1:(i2-1) );
    end
end
