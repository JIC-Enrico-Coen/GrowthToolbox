function n = triangleIndexes( p )
%n = triangleIndexes( p )
%   Calculate the set of triangle node indexes corresponding to the given
%   prism node vertexes.

    n = unique( floor( (p+1)/2 ) );
end
