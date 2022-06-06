function pts = randInSphere( n )
%pts = randOnSphere( n )
%   Choose n points uniformly distributed at random throughout the unit sphere.

    pts = randOnSphere( n ) .* repmat( sqrt(rand(n,1)), 1, 3 );
end
