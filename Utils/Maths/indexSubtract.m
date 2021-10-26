function i = indexSubtract( i, d, n )
%i = indexSubtract( i, d, n )
%   If i is an index into an array of length n, and d is an amount we want
%   to subtract from i, to get a new index into the array, wrapping round
%   the ends if necessary, then the result is that index.
    i = mod(i-d-1,n) + 1;
end
