function approxsign = approxCompare( x, y, tol )
%approxsign = approxCompare( x, y, tol )
%   This is like the sign() function, but allows for a tolerance. When the
%   result is -1, x is definitely less than y. When it is 1, X s
%   definitely more than Y. When it is 0, X and Y are close to each other.
%
%   X and Y can be arrays of the same shape, or either can be a scalar and
%   the other an array.
%
%   See also: approxComparison

    if numel(x)==1
        approxsign = zeros(size(y));
    else
        approxsign = zeros(size(x));
    end
    
    approxsign( x < y-tol ) = -1;
    approxsign( x > y+tol ) = 1;

%     if t1 < t2-tol
%         approxsign1 = -1
%     elseif t1 > t2+tol
%         approxsign1 = 1
%     else
%         approxsign1 = 0
%     end
end
