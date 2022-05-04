function isat = meshAtOrBeforeTime( m, t, varargin )
%isat = meshAtOrBeforeTime( m, t, tolerance )
%   Test to see if the current simulation time is at or before the time T,
%   allowing for numerical rounding error.  The tolerance is a fraction of
%   the current timestep, and defaults to 0.01.  This function returns true
%   if the current time does not exceed T by this amount or more.
%
%   meshAtOrBeforeTime( m, t, tolerance ) is exactly equivalent to
%   ~meshAfterTime( m, t, tolerance ).
%
%   SEE ALSO: meshAtTime, meshAfterTime, meshBeforeTime,
%       meshAtOrAfterTime, meshCompareTime

%     if nargin < 3
%         tolerance = 0.01;
%     end
%     absTolerance = m.globalProps.timestep*tolerance;
%     isat = m.globalDynamicProps.currenttime < t + absTolerance;
    isat = meshCompareTime( m, t, 'le', varargin{:} );
end

