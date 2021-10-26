function q = quatLocalToGlobal( q1, q2 )
% q = quatLocalToGlobal( q1, q2 )
%   Express in the global frame the effect of quaternion q2 performed in
%   the frame of reference q1.
%   The result is q1 * q2 * inv(q1).

    q = quatProd( q1, quatProd( q2, quatInv( q1 ) ) );
end