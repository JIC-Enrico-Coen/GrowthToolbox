function a = altitudeVector( vxs, p )
%a = altitudeVector( vxs, p )
%   Find the altitude vector from a line segment to a point.  VXS is a 3*2 vector
%   containing the ends of the segment.

    a = nearestPointOnLine( vxs, p );
    a = p - a;
end
