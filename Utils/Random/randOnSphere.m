function pts = randOnSphere( n, radius )
%pts = randOnSphere( n )
%   Choose n points in 3 dimensions uniformly distributed at random over
%   the surface of the sphere. of given radius centred at the origin.
%   Radius defaults to 1.

    if nargin < 2
        radius = 1;
    end
    if radius==0
        pts = zeros( n, 3 );
    else
        x = 1 - rand(n,1)*2;
        y = sqrt(1-x.*x);
        phi = rand(n,1)*2*pi;
        pts = radius * [ y.*cos(phi), y.*sin(phi), x ];
    end
end
