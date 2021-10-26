function [ticks,ranks] = scaleticks( lo, hi )
%[ticks,ranks] = scaleticks( lo, hi )
%   Given a scale ranging from lo to hi, choose suitable values to put tick
%   marks against.
%   0, if within the range and not too close to a nonzero endpoint, always gets a tick.
%   We scale the range so that the end with larger magnitude has nagnitude
%   between 1 and 10.  Then we choose ticks at all the integer points in
%   the range, or more finely if that doesn't give enough ticks.  Finally,
%   we force the endpoints to receive ticks.
%   ranks specifies which of the ticks are major and which minor -- for
%   example, in order to draw the major ones thicker than the minor ones.
%   0 is always a major rank.  Currently, it is the only major rank.
%   The higher the rank, the more important the tick mark.  The number is
%   actually the line thickness in pixels.

    if lo == hi
        % Empty range, just a single tick.
        ticks = hi;
        ranks = 1;
        return;
    end
    if lo > hi
        % Want hi to be the larger.
        [ticks,ranks] = scaleticks( hi, lo );
        return;
    end
    if -lo > hi
        % The negative range is greater than the positive range.  Swap,
        % negate, and negate the result.
        [ticks,ranks] = scaleticks( -hi, -lo );
        ticks = -ticks;
        return;
    end
    
    if isinf(hi)
        if isinf(lo)
            lo = 0; hi = 1;
        else
            hi = lo+1;
        end
    elseif isinf(lo)
        lo = hi-1;
    end
    
    % Scale hi to be in the range (1..10].
    tens = 0;
    while hi > 10
        hi = hi/10;
        lo = lo/10;
        tens = tens+1;
    end
    while hi <= 1
        hi = hi*10;
        lo = lo*10;
        tens = tens-1;
    end
    
    % Put ticks at all integer points within the range.
    step = 1;
    ticks = ceil(lo):step:floor(hi);
    
    % If that isn't enough ticks, use finer subdivisions.
    MINTICKS = 5;
    stepi = 1;
    steps = [2 4 5];
    while (length(ticks) < MINTICKS) && (stepi <= length(steps))
        step = steps(stepi);
        ticks = (ceil(lo*step) : floor(hi*step))/step;
        stepi = stepi+1;
    end
    ismajortick = ticks==round(ticks);
    if all(ismajortick)
        ismajortick(:) = false;
    end
    ismajortick((ticks==5) | (ticks==10)) = true;
    ranks = ismajortick+1;
    ranks( ticks==0 ) = 3;
    
    % Force the endpoints to receive ticks.  If an endpoint is sufficiently
    % far away from the tick at that end of the scale, add it as a new
    % tick, otherwise replace the end tick by the endpoint.
    if isempty(ticks)
        ticks = [lo hi];
        ranks = [1 1];
    else
        topgap = hi - ticks(end);
        MINGAP = 0.25/step;
        if topgap > MINGAP
            ticks(end+1) = hi;
            ranks(end+1) = 1;
        elseif topgap > 0
            ticks(end) = hi;
        end
        bottomgap = ticks(1) - lo;
        if bottomgap > MINGAP
            ticks = [ lo ticks ];
            ranks = [ 1 ranks ];
        else
            ticks(1) = lo;
        end
    end
%     ranks = ones(size(ticks));
%     ranks(ticks==0) = 3;
%     ranks(ticks==5) = 2;
%     if ranks(1)==1
%         ranks(1) = 1.1;
%     end

    % Restore the factors of ten we took out.
    ticks = ticks * 10^tens;
end
