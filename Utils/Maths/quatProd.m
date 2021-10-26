function q = quatProd( q1, q2 )
% q = quatProd( q1, q2 )
%   Calculate the product of the quaternions q1*q2.
%   The quaternions are expected in the form of 1x4 vectors in the order
%   x,y,z,w.

    q = [ q1(2)*q2(3) - q1(3)*q2(2) + q1(1)*q2(4) + q1(4)*q2(1), ...
          q1(3)*q2(1) - q1(1)*q2(3) + q1(2)*q2(4) + q1(4)*q2(2), ...
          q1(1)*q2(2) - q1(2)*q2(1) + q1(3)*q2(4) + q1(4)*q2(3), ...
          -q1(1)*q2(1) - q1(2)*q2(2) - q1(3)*q2(3) + q1(4)*q2(4) ];
end