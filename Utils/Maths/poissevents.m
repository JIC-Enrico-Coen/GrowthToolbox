function [numevents,times] = poissevents( rate, duration )
%[numevents,times] = poissevents( rate, duration )
%   This is equivalent to (and calls) numevents = poissrnd(rate*duration),
%   but in addition returns the times at which the events happen.
%   Conditional on the number of events, these are uniformly distributed in
%   the range from 0 to duration.
%
%   Duration defaults to 1.
%
%   SEE ALSO: poissrnd

    if nargin < 2
        duration = 1;
    end
    numevents = poissrnd( rate*duration );
    times = rand( 1, numevents ) * duration;
end
