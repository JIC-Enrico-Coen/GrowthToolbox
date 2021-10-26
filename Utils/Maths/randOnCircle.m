function pts = randOnCircle( n )
%pts = randOnSphere( n )
%   Choose n points uniformly distributed at random over the circumference
%   of the unit circle.

    theta = rand(n,1)*(2*pi);
    pts = [ cos(theta), sin(theta) ];
end
