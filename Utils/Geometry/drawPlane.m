function h = drawPlane( ax, normal, distance, radius, alph )
%h = drawPlane( ax, normal, distance, radius, alph )
%   In the axes AX, draw a rectangle in the plane whose unit normal vector
%   is NORMAL, and which is a DISTANCE from the origin.  The semidiameter
%   of the rectangle is RADIUS and its alpha value is ALPH.  The centre of
%   the rectangle will be at the closest point of the plane to the origin.
%   NORMAL must be a row vector.

	v = findPerpVector( normal );
    w = cross(v,normal);
    rv = radius*v;
    rw = radius*w;
    origin = normal*distance;
    pts = [ origin+rv+rw; ...
            origin+rv-rw; ...
            origin-rv-rw; ...
            origin-rv+rw ];
    h = fill3( pts(:,1), pts(:,2), pts(:,3), [0 1 1], 'Parent', ax, 'FaceAlpha', alph );
 %  p = projectPointToPlane2( point, normal, distance )
end
