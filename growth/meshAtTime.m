function isat = meshAtTime( m, t, tolerance )
%isat = meshAtTime( m, t, tolerance )
%   Test to see if the current simulation time is close to the time T.  The
%   tolerance is a fraction of the current timestep, and defaults to 0.01.
%   The function returns true if the simulation time is within this
%   interval of T.
%
%   SEE ALSO: meshAfterTime, meshBeforeTime, meshAtOrAfterTime,
%       meshAtOrBeforeTime

    if nargin < 3
        tolerance = 0.01;
    end
    absTolerance = m.globalProps.timestep*tolerance;
    isat = abs(m.globalDynamicProps.currenttime - t) < absTolerance;
end

