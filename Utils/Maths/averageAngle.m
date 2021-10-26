function [a,m,var] = averageAngle( angles, weights )
%a = averageAngle( angles, weights )
%   Take the weighted average of the given angles.  If there are N angles,
%   there are N candidates for the average, depending on which candidate
%   value is selected for each angle.  Choose the one that minimises the
%   variance.  If there is more than one, choose one at random.
%   The angles are assumed to be in radians.

    numangles = length(angles);
    if numangles==0
        a = 0;
        return;
    end
    if nargin < 2
        weights = ones(size(angles))/numangles;
    end
    [angles,perm] = sort( normaliseAngle( angles, -pi, false ) );
    weights = weights(perm);
    m = zeros(1,numangles);
    var = zeros(1,numangles);
    twopi = pi+pi;
    for i=1:numangles
        m(i) = sum(angles.*weights);
        var(i) = sum(angles.*angles.*weights) - m(i)*m(i);
        angles(i) = angles(i) + twopi;
    end
    is = find( var==min(var) );
    a = normaliseAngle( m( randelement(is) ), -pi, false );
end
