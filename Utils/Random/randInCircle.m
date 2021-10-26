function r = randInCircle( n, radius )
% Uniform distribution in the unit circle.
  angle = 2.0 * pi * rand(1,n);
  radius = radius * sqrt ( rand(1,n) );

  r(1,1:n) = radius .* cos ( angle );
  r(2,1:n) = radius .* sin ( angle );
end

