function q = quatInv( q )
% q = quatInv( q )
%   Calculate the inverse of the quaternion.
%   The quaternion is expected in the form of a 1x4 vector in the order
%   x,y,z,w.  It may also be an N*4 matrix of N quaternions, and the result
%   will have the same shape.

%   Since 

    q(:,1:3) = -q(:,1:3);
end