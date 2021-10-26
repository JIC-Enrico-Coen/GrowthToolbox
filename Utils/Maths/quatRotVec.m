function v = quatRotVec( q, v )
% v = quatRotVec( q, v )
%   Rotate the vector v by the quaternion q.

%     qv = [ v, 0 ];
%     qv1 = quatLocalToGlobal( q, qv );
%     v = qv1(1:3);
    
    v = reshape( quatToMatrix(q)*v(:), size(v) );
end