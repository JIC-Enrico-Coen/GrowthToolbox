function r = randFromDist( dist, n )
%r = randFromDist( dist, n )
%   Select N random indexes into a distribution given by DIST.  Each index
%   will be chosen with probability proportional to its value in DIST.

    c = cumsum(dist);
    p = rand(1,n)*c(end);
    r = binsearchupper( c, p );
end
