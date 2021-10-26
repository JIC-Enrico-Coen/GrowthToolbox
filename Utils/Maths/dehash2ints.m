function [x, y] = dehash2ints( z )
%[x, y] = dehash2ints( z )
%   If z is a hash of two non-negative ints as computed by hash(x,y),
%   recover x and y.  z may be of any shape, and x and y will be the same
%   shape.  x and y always have type int32.
%
%   If z was the result of hash2ints( x, y, 'sym' ), then the resulting x
%   and y will have x <= y everywhere.

    xy = int32( floor( (sqrt(1+8*double(z-1))-1)/2 ) );
    y = z-1-(xy.*(xy+1))/2;
    x = int32( xy-y );
end
