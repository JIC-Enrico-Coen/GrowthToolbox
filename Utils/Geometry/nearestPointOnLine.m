function [a,bc] = nearestPointOnLine( vxs, p )
%a = nearestPointOnLine( vxs, p )
%   VXS is a 3*2 vector containing the ends of a line segment.
%   a is set to the point on that line that is closest to p.  (a is not
%   restricted to be within the line segment.)

    yx = vxs(2,:) - vxs(1,:);
    zx = p - vxs(1,:);
    yxsq = dot(yx,yx);
    if yxsq==0
        a = vxs(1,:);
        bc = 0;
    else
        bc = dot(zx,yx)/dot(yx,yx);
        a = vxs(1,:) + bc*yx;
    end
end
