function l = sinelength( a, p )
%l = sinelength( a )
%   Compute the arc length of a sine wave of amplitude A and period P.

    N = 1000;
    dX1 = pi/(2*N);
    dX2 = p/(4*N);
    S = sin( (0:N)*dX1 );
    dS = S(2:(N+1)) - S(1:N);
    dY = a(:) * dS;
    l = 4*sum( sqrt(dY.^2 + dX2*dX2), 2 );
  % fprintf( 1, '%.8f\n', l);
end
