function v = convert22matrixTo3vector( m )
%v = convert22matrixTo3vector( m )
%   Convert a tensor in symmetric 2x2 matrix form to a 3-vector.
%   m may be a 2x2xN matrix representing N tensors, and v will be Nx3.

    v = [ m(1,1,:), m(2,2,:), m(2,1,:)+m(1,2,:) ];
    v = permute( v, [3 2 1] );
end
