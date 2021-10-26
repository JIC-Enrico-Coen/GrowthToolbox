function [b,v] = lineIntersection( v1, v2, v3, v4, allowoutside )
%[b,v] = lineIntersection( v1, v2, v3, v4 )
%   Find the intersection of the lines v1 v2 and v3 v4.
%   The vectors must be 2-dimensional column vectors.
%   b is true if the line segments intersect. v is the intersection.
%   v is not computed unless asked for.
%
%   If allowoutside is false (the default) then v will be returned as empty if
%   it is asked for and the line segments do not intersect.

    if nargin < 5
        allowoutside = false;
    end

    i = pinv( [ v1-v2, v4-v3 ] );
    a = i * (v4-v2);
    b = all( (a >= 0) & (a <= 1) );
    if nargout > 1
        if b || allowoutside
            v = a(1)*v1 + (1-a(1))*v2;
        else
            v = [];
        end
    end
  % v1 = c(2)*v3 + (1-c(2))*v4
end
