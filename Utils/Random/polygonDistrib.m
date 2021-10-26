function distrib = polygonDistrib( poly )
%distrib = polygonDistrib( poly )
%   Returns a structure representing the distribution function for the x
%   coordinate of a random variable uniformly distributed over the polygon.
%   The polygon is specified as an N*2 matrix.

    density = polygonDensity( poly );
    distrib = distribPLC( density );
end