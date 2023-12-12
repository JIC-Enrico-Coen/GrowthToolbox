function s = evolveStreamline( m, s, t, noncolliders )
%s = evolveStreamline( m, s, t, noncolliders )
%   Evolve the streamline for the given time.
% INCOMPLETE 2019 Jun 25
% OBSOLETE 2023 Jul 20

    remainingtime = t;
    while remainingtime > 0
        if s.status.head==1
            [eventtime,eventtype] = firstTime( s.params.prob_plus_catastrophe, remainingtime );
            [s,lengthgrown] = extendStreamline( m, s, eventtime*s.params.plus_growthrate, noncolliders );
            remainingtime = 
        else
        end
    end
end

function [t,pi] = firstTime( p, maxtime )
%t = firstTime( p )
%   P is a set of probabilities, each describing a Poisson process whose
%   probability of an event is p per unit time.  All of these processes are
%   imagined to run concurrently. The result is the time of the first event,
%   and which member of P is associated with it.
%
%   If MAXTIME is given and none of the events happen before then, then
%   t=MAXTIME and pi=0.

    [t,pi] = min( 1 - exp(-p(:)) );
    if (nargin > 1) && (t > maxtime)
        t = maxtime;
        pi = 0;
    end
end
