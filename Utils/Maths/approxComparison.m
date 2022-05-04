function is = approxComparison( x, y, comparison, tolerance )
%isat = approxComparison( x, y, comparison, tolerance )
%   Compare X and Y, allowing for numerical rounding error.  TOLERANCE is
%   an absolute quantity, and defaults to
%   0.01 * max( max(abs(X(:))), max(abs(Y(:))) ).
%   Setting TOLERANCE to zero gives exact comparisons.
%
%   COMPARISON is one of 'lt', 'le', 'eq', 'ge', or 'gt'. Any other value
%   will return false.
%
%   X and Y can be arrays of the same shape, or either can be a scalar and
%   the other an array.
%
%   It is guaranteed that the comparisons for 'lt' and 'ge' have opposite
%   truth values, and the same for 'le' and 'gt'. 'eq' is  equivalent to
%   'le' and 'ge'.
%
%   'lt' and 'gt' are transitive, but 'le', 'eq', and 'ge' are not.
%
%   See also: approxCompare

    if nargin < 4
        tolerance = 0.01 * max( max(abs(x(:))), max(abs(y(:))) );
    end
    delta = x - y;
    switch comparison
        case 'lt'
            is = delta <= -tolerance;
        case 'le'
            is = delta < tolerance;
        case 'gt'
            is = delta >= tolerance;
        case 'ge'
            is = delta > -tolerance;
        case 'eq'
            is = abs(delta) < tolerance;
        otherwise
            is = false(size(y));
    end
end

