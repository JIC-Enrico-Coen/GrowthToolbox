function [segindexes, segbc, tt] = samplePiecewiseConstant( probs, lengths, t, order )
% [segindexes, segbc] = samplePiecewiseConstant( probs, lengths, t )
%   A line is divided into segments whose lengths are LENGTHS. For each
%   segment a probability density is given in PROBS (whose length is equal
%   to the length of LENGTHS).
%
%   In time t some number of events will randomly happen. This procedure
%   calculates how many and exactly where they are on the line.
%
%   For each event, TT records when in the interval from 0 to t each
%   event occurred.
%
%   By default, the results are returned in order of their position along
%   the line. If ORDER is specified and is 'timeorder', then they are
%   returned in time order.

    timeorder = (nargin > 3) && strcmpi( order, 'timeorder' );

    % Determine how many events happen in each segment.
    eventsPerSegment = poissrnd( (probs.*lengths)*t );
    numevents = sum(eventsPerSegment);
    
    % Find the segment index for each event.
    segindexes = zeros(numevents,1);
    si = 0;
    for i=1:length(eventsPerSegment)
        ne = eventsPerSegment(i);
        if ne > 0
            segindexes( (si+1):(si+ne) ) = i;
            si = si+ne;
        end
    end
    
    % Each event is uniformly distributed within its segment.
    segbc = rand(numevents,1);
    
    if (nargout >= 3) || timeorder
        tt = rand(numevents,1) * t;
    end
    
    if timeorder
        [tt,perm] = sort(tt);
        segindexes = segindexes(perm);
        segbc = segbc(perm);
    end
    
    segbc = [ 1-segbc, segbc ];
end
