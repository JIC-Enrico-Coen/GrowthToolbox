function isat = meshBeforeTime( m, t, tolerance )
%isat = meshBeforeTime( m, t, tolerance )
%   Test to see if the current simulation time is after the time T,
%   allowing for numerical rounding error.  The tolerance is a fraction of
%   the current timestep, and defaults to 0.01. To be counted as before T,
%   the current time must fall short of it by at least this amount.
%
%   meshBeforeTime( m, t, tolerance ) is exactly equivalent to
%   ~meshAtOrAfterTime( m, t, tolerance ).
%
%   SEE ALSO: meshAtTime, meshAfterTime, meshAtOrAfterTime,
%       meshAtOrBeforeTime

    if nargin < 3
        tolerance = 0.01;
    end
    absTolerance = m.globalProps.timestep*tolerance;
    isat = m.globalDynamicProps.currenttime <= t - absTolerance;
end

