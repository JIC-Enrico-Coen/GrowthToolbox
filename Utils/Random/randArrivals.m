function times = randArrivals( lambda, t )
%t = randArrivals( lambda, n )
%   LAMBDA is the rate parameter of a Poisson process. T is a time that
%   elapses.  TIMES will be the times of events happening in that time, in
%   ascending order. On average there will be LAMBDA*T of them, with
%   sqrt(LAMBDA*T) standard deviation.

    remainingtime = t;
    times = zeros( ceil(1/lambda), 1 );
    numevents = 0;
    while remainingtime > 0
        t1 = expinv( rand(1), 1/lambda );
        if t1 < remainingtime
            numevents = numevents+1;
            times(numevents) = t1;
            remainingtime = remainingtime - t1;
        else
            break;
        end
    end
    times( (numevents+1):end ) = [];
    times = cumsum(times);
end
