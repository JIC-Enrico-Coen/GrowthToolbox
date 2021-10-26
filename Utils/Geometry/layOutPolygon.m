function vxs = layOutPolygon( edges, angles )
%vxs = layOutPolygon( edges, angles )
%   Given the set of edge lengths and exterior angles of a polygon,
%   calculate its vertexes in the plane.  The first vertex is placed at the
%   origin and the second on the positive x axis.
%   If the exterior angles do not sum to 2pi, they will be adjusted to fit.

    s = sum(angles);
    na = length(angles);
    excess = pi*2-s;
    angles = angles + excess/na;
    vxs = zeros( na, 2 );
    v = [ 0, 0 ];
    a = 0;
    vxs(1,:) = v;
    for i=1:na-1
        v = v + edges(i)*[ cos(a), sin(a) ];
        vxs(i+1,:) = v;
        a = a + angles(i+1);
    end
    v = v + edges(na)*[ cos(a), sin(a) ];
    err = vxs(1,:) - v;
    totlen = sum(edges);
    len = edges(1);
    for i=2:na
        vxs(i,:) = vxs(i,:) + err*len/totlen;
        len = len + edges(i);
    end
    v = v + err*len/totlen;
  % errerr = v - vxs(1,:)
end
