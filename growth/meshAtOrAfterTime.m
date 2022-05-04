function isat = meshAtOrAfterTime( m, t, varargin )
%isat = meshAtOrAfterTime( m, t, tolerance )
%   Test to see if the current simulation time is at or after the time T,
%   allowing for numerical rounding error.  The tolerance is a fraction of
%   the current timestep, and defaults to 0.01.  Thus function returns true
%   if the current time does not fall below T by this tolerance or more.
%
%   meshAtOrAfterTime( m, t, tolerance ) is exactly equivalent to
%   ~meshBeforeTime( m, t, tolerance ).
%
%   SEE ALSO: meshAtTime, meshAfterTime, meshBeforeTime,
%       meshAtOrBeforeTime, meshCompareTime

%     if nargin < 3
%         tolerance = 0.01;
%     end
%     absTolerance = m.globalProps.timestep*tolerance;
%     isat = m.globalDynamicProps.currenttime > t - absTolerance;
    
    isat = meshCompareTime( m, t, 'ge', varargin{:} );
end

