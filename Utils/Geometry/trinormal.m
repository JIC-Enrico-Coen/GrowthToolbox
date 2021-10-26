function normal = trinormal( t )
%normal = trinormal( t )    Calculate a normal vector to the
%triangle whose vertices are the rows of t.  The length of the vector is twice
%the area of the triangle.
%If the three points are collinear, the vector will be zero.
    normal = crossproc2( t(2,:)-t(1,:), t(3,:)-t(1,:) );
end
