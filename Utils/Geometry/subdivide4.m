function p = subdivide4( v, k )
%p = subdivide4( v )
%   Given a 4*3 matrix holding four points, find a point on a smooth curve
%   through the four points, about halfway between the middle two points.

    if nargin < 2
        k = 0.125;
    end

    p = [ -k 0.5+k 0.5+k -k ] * v;
    return;

%   The coefficients here are chosen so that if the four points are
%   consecutive vertexes of a regular hexagon, the interpolating point is
%   on the circumcircle.  For a regular polygon of fewer sides, it will be
%   inside the circumcircle, and for more sides, outside.

    k = (8-4*sqrt(3))/3;
    scale = k*norm(v(3,:)-v(2,:));
    w1 = v(3,:)-v(1,:);
    w1 = w1 * (scale/norm(w1));
    w2 = v(2,:)-v(4,:);
    w2 = w2 * (scale/norm(w2));
    
    p = (w1+w2)*(3/8) + (v(2,:)+v(3,:))*(4/8);

  % p = (v(2,:) + v(3,:)) * a + (v(1,:) + v(4,:)) * b;
end
