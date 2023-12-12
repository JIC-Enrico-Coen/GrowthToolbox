function x = trimnumber( lo, x, hi, tol )
%x = trimnumber( lo, x, hi, tol )
%   Force every element of x to lie within lo..hi.  x may be a numerical
%   array of any size and shape.
%
%   If x lies within tol of either endpoint, it is mapped to that endpoint.
%   If hi and lo are within tol of each other, every value is mapped to lo.
%   tol defaults to zero.
%
%   NaN values are mapped to NaN.

    x = max( lo, min( hi, x, 'includenan' ), 'includenan' );
    
    if nargin > 3
        x(x > hi-tol) = hi;
        x(x < lo+tol) = lo;
    end
end
