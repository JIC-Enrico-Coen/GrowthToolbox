function [segindexes, segbc, tt] = samplePiecewiseLinear( probs, lengths, t, order )
%[segindexes, segbc, times] = samplePiecewiseLinear( probs, lengths, t, order )
%   A line is divided into segments whose lengths are LENGTHS. At each
%   vertex a probability density is given in PROBS (whose length is 1 more
%   than the length of LENGTHS). ORDER is optional.
%
%   In time T some number of events will randomly happen. This procedure
%   calculates how many, where they are on the line, and when they
%   occurred.
%
%   For each event, TT records when in the interval from 0 to t each
%   event occurred.
%
%   By default, the results are returned in order of their position along
%   the line. If ORDER is specified and is 'timeorder', then they are
%   returned in time order.

    timeorder = (nargin > 3) && strcmpi( order, 'timeorder' );

    % Calculate the total number of events.
    segprobs = (probs(1:(end-1)) + probs(2:end)).*lengths/2;
    eventsPerSegment = poissrnd( segprobs * t );
    eventsPerSegment(isnan(eventsPerSegment)) = 0; % poissrnd returns NaN for a negative parameter.
    numevents = sum(eventsPerSegment);
    
    % Find the segment index and position within each segment for each event.
    segindexes = zeros(numevents,1);
    segbc = zeros(numevents,1);
    si = 0;
    for i=1:length(eventsPerSegment)
        ne = eventsPerSegment(i);
        if ne > 0
            eventRange = (si+1):(si+ne);
            segindexes( eventRange ) = i;
            segbc( eventRange ) = sort( randInLinearGradient( probs([i i+1]), ne ) );
            si = si+ne;
        end
    end
    
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
