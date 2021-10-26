function q = quatNormalise( q )
% q = quatNormalise( q )
%   Normalise the quaternion to unit length.
%   The quaternion is expected in the form of a 1x4 vector in the order
%   x,y,z,w.  It may also be an N*4 matrix of N quaternions, and the result
%   will have the same shape.

    norms = sum( q.^2, 2 );
    nz = norms~=0;
    q(nz,:) = q(nz,:) ./ repmat( norms(nz), 1, 4 );
end