function [ok,v,bc12,bc34,vcheck,verr] = lineIntersection( v1, v2, v3, v4, allowoutside )
%[b,v,bc] = lineIntersection( v1, v2, v3, v4 )
%   Find the intersection of the lines v1 v2 and v3 v4.
%   The vectors must be 2-dimensional column vectors.
%   b is true if the line segments intersect. v is the intersection.
%   bc12 is the barycentris coordinartes of v with respect to v1 and v2,
%   and b34 likewise with respect to v3 and v4. v is defined to be
%   bc12(1)*v1 + bc12(2)*v2. This should be identical, up to rounding
%   error, to bc34(1)*v3 + bc34(2)*v4, unless the lines are exactly
%   parallel. The closer to parallel they are, the larger the rounding
%   error is likely to be.
%
%   If allowoutside is false (the default) then v, bc12, and bc34 will be
%   returned as empty if the line segments do not intersect, and ok will be
%   false. In all other cases the values are returned and ok is true.
%
%   The output arguments vcheck and verr were added for debugging
%   purposes. vcheck is the value bc34(1)*v3 + bc34(2)*v4 and verr is
%   vcheck-v. If these arguments are requested, a diagram of the points
%   will be drawn.

    if nargin < 5
        allowoutside = false;
    end

    iv = pinv( [ v1-v2, -v3+v4 ] );
    a = iv * (v4-v2);
    ok = all( (a >= 0) & (a <= 1) );
    bc12 = [a(1), 1-a(1)];
%     a2 = i * (v1-v3);
%     a12_ok = all( (a2 >= 0) & (a2 <= 1) );
    bc34 = [a(2), 1-a(2)];
    if ok || allowoutside
        v = bc12(1)*v1 + bc12(2)*v2;
        % This should be identical, to within rounding error, to
        % bc34(1)*v3 + bc34(2)*v4.
    else
        v = [];
        bc12 = [];
        bc34 = [];
    end
  
    PLOT = (nargout >= 5) && ~isempty(v);
    if PLOT
        vcheck = bc34(1)*v3 + bc34(2)*v4;
        verr = v-vcheck;
        [f,ax] = getFigure();
        hold on
        plotpts( v', 'Parent', ax, 'Marker', '.', 'MarkerSize', 20, 'Color', boolchar( ok, 'b', 'r' ) );
        plotpts( vcheck', 'Parent', ax, 'Marker', 'o', 'MarkerSize', 20, 'Color', boolchar( ok, 'b', 'r' ) );
        plotlines( [1 2;3 4], [v1 v2 v3 v4]', 'Parent', ax, 'Marker', '.', 'MarkerSize', 10, 'LineStyle', '-', 'LineWidth', 1, 'Color', 'k' );
        hold off
        axis equal
    end
end
