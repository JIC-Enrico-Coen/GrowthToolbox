function pts = randInRectangle( n, bbox )
%pts = randInRectangle( n, bbox )
%   Generate a random set of points uniformly distributed in a rectangle.
%   bbox gives the bounds as [xlo, xhi, ylo, yhi].
%   The result is an N*2 array.

    lowerbound = bbox([1 3]);
    range = bbox([2 4]) - lowerbound;

    pts = rand(n,2).*range + lowerbound;
end

