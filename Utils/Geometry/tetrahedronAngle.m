function a = tetrahedronAngle( v1, v2, v3, v4 )
%a = tetrahedronAngle( v1, v2, v3, v4 )
%  The arguments are the four vertices of a tetrahedron.
%   Return the angle between the two faces joined by the edge v1 v2.

    v1a = findAltitude( v1, v3, v4 );
    v2a = findAltitude( v2, v3, v4 );
    a = vecangle( v1-v1a, v2-v2a );
end
