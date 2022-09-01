function r = randOnCircle( n, radius )
% Uniform distribution on the circumference of the unit circle.

  angle = 2.0 * pi * rand(n,1);
  r = radius * [ cos( angle ), sin( angle ) ];
end

