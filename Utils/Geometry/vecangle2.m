function theta = vecangle2( a, b )
%theta = vecangle2( a, b )
%   Calculate the angle between two vectors in the plane, or any number of
%   pairs of vectors.  The angle is signed, in the range (-pi...pi], and
%   represents an anticlockwise rotation from the first vector to the
%   second.

    c = a(:,1).*b(:,1) + a(:,2).*b(:,2);
    s = a(:,1).*b(:,2) - a(:,2).*b(:,1);
    theta = atan2( s, c );
end
