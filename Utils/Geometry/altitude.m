function d = altitude( vxs, p )
%d = altitude( vxs, p )
%   Find the altitude of a point from a line segment.  VXS is a 3*2 vector
%   containing the ends of the segment.

    v21 = vxs(2,:)-vxs(1,:);
    nv21 = norm(v21);
    if nv21==0
        d = 0;
    else
        d = norm(cross( p - vxs(1,:), v21 ))/nv21;
    end
end
