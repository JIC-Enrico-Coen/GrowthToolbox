function z = hash2ints( x, y, sym )
%z = hash2ints( x, y, sym )
%   Given two non-negative integers x and y, calculate an integer z such
%   that z uniquely determines x and y.  z will always be of type int32.
%   z is positive, and therefore a valid array index.  (Because this is a
%   useful property to have.)
%
%   This can also be applied to two arrays of the same shape.  z will be
%   the same shape.
%
%   If a single argument of size N*2 is given, the two columns are taken as
%   the x and y values, and z will be N*1.
%
%   hash2ints( x, y, 'sym' ) is equivalent to hash2ints( min(x,y), max(x,y) ).
%
%   See also: dehash2ints.

    splitarg = false;
    switch nargin
        case 1
            splitarg = true;
            sym = false;
        case 2
            if ischar(y)
                sym = strcmp(y,'sym');
                splitarg = true;
            else
                sym = false;
            end
        case 3
            sym = strcmp(sym,'sym');
    end
    
    if splitarg
        y = x(:,2);
        x = x(:,1);
    end
    
    if sym
        y1 = max(x,y);
        x = min(x,y);
        y = y1;
    end

    z = 1 + int32( ((x+y).^2 + x + 3*y)/2 );
end
