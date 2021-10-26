function q = quatGlobalToLocal( q1, q2 )
% q = quatLocalToGlobal( q1, q2 )
%   Express in the local frame q1 the effect of quaternion q2 performed in
%   the global frame.
%   The result is inv(q1) * q2 * q1.

    q = quatProd( quatInv( q1 ), quatProd( q2, q1 ) );
end