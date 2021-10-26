function startTic = startTimingGFT( h, m )
%startTic = startTimingGFT( h, m )
%   If the timeCommandsItem menu item is toggled on, then start a timer.
%   If the timer was started, startTic is the result of calling tic(), and
%   otherwise is zero.  In either case, startTic can be supplied to the
%   procedure stopTimingGFT().
%
%   See also: stopTimingGFT.

    if nargin > 1
        h = getGFtboxHandles(m);
    end

    if ~isempty(h) && isfield( h, 'timeCommandsItem' ) && ischeckedMenuItem( h.timeCommandsItem )
        startTic = tic();
    else
        startTic = 0;
    end
end
