function isat = meshAfterTime( m, t, tolerance )
%isat = meshAtOrAfterTime( m, t, tolerance )
%   Test to see if the current simulation time is after the time T,
%   allowing for numerical rounding error.  The tolerance is a fraction of
%   the current timestep, and defaults to 0.01. To be counted as after T,
%   the current time must exceed it by at least this amount.
%
%   meshAfterTime( m, t, tolerance ) is exactly equivalent to
%   ~meshAtOrBeforeTime( m, t, tolerance ).
%
%   SEE ALSO: meshAtTime, meshBeforeTime, meshAtOrAfterTime,
%       meshAtOrBeforeTime

    if nargin < 3
        tolerance = 0.01;
    end
    absTolerance = m.globalProps.timestep*tolerance;
    isat = m.globalDynamicProps.currenttime >= t + absTolerance;
end

