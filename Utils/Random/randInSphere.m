function pts = randInSphere( n, radius )
%pts = randOnSphere( n, radius )
%   Choose n points in 3 dimensions uniformly distributed at random
%   throughout the sphere of given radius centred at the origin. Radius
%   defaults to 1.

    if nargin < 2
        radius = 1;
    end
    if radius==0
        pts = zeros( n, 3 );
    else
        pts = randOnSphere( n, radius ) .* repmat( sqrt(rand(n,1)), 1, 3 );
    end
end
