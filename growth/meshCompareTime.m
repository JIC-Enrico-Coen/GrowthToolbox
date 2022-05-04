function result = meshCompareTime( m, t, comparison, tolerance )
%result = meshCompareTime( m, t, comparison, tolerance )
%   Compare the current simulation time with the time T, allowing for
%   numerical rounding error.  The tolerance is a fraction of
%   the current timestep, and defaults to 0.01. The comparison is one of
%   'lt', 'le', 'eq', 'ge', or 'gt'.
%
%   T can be an array of times, in which case IS is boolean array of the
%   same shape.
%
%   It is guaranteed that the comparisons for 'lt' and 'ge' always have
%   opposite truth values, and the same for 'le' and 'gt'. 'eq' is
%   equivalent to 'le' and 'ge'.
%
%   SEE ALSO: meshAtOrBeforeTime, meshBeforeTime, meshAtTime,
%       meshAtOrAfterTime, meshAfterTime, approxComparison

    if nargin < 4
        tolerance = 0.01;
    end
    absTol = m.globalProps.timestep*tolerance;
    result = approxComparison( m.globalDynamicProps.currenttime, t, comparison, absTol );
%     delta = m.globalDynamicProps.currenttime - t;
%     switch comparison
%         case 'lt'
%             is = delta <= -absTol;
%         case 'le'
%             is = delta < absTol;
%         case 'gt'
%             is = delta >= absTol;
%         case 'ge'
%             is = delta > -absTol;
%         case 'eq'
%             is = abs(delta) < absTol;
%         otherwise
%             is = false(size(t));
%     end
end

