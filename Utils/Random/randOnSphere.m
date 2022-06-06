function pts = randOnSphere( n )
%pts = randOnSphere( n )
%   Choose n points uniformly distributed at random over the surface of the
%   unit sphere.

    x = 1 - rand(n,1)*2;
    y = sqrt(1-x.*x);
    phi = rand(n,1)*2*pi;
    pts = [ y.*cos(phi), y.*sin(phi), x ];
end
