function pts = randInPoly( n, poly )
%pts = randInPoly( n, poly )
%   Generate a random set of points uniformly distributed in the polygon
%   POLY in the plane.
%   POLY is a K*2 matrix listing the points of the polygon in
%   anticlockwise order.
%
%   The result is an N*2 matrix.

    distrib = polygonDistrib( poly );
    pts = randpoly( distrib, n );
end

