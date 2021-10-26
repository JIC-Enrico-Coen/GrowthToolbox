function v = convert33matrixTo6vector( m )
%v = convert33matrixTo6vector( m )
%   Convert a tensor in symmetric 3x3 matrix form to a 6-vector.
%   m may be an 3x3xN matrix representing N tensors, and v will be Nx3.

    v = [ m(1,1,:), m(2,2,:), m(3,3,:),...
          m(2,3,:)+m(3,2,:), m(3,1,:)+m(1,3,:), m(1,2,:)+m(2,1,:) ];
    v = permute( v, [3 2 1] );
end
