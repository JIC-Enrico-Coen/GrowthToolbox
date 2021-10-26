function m = convert6vectorTo33matrix( v )
%m = convert6vectorTo33matrix( v )
%   Convert a tensor in 6-vector form to a symmetric 3x3 matrix.
%   v may be an N*6 matrix representing N tensors, and m will be 3x3xN.

    symmetrycount = 2;
    v(:,4:6) = v(:,4:6)/symmetrycount;
%     m = [ v(1), v(6), v(5); ...
%           v(6), v(2), v(4); ...
%           v(5), v(4), v(3) ];
      
    m = reshape( v(:,[1 6 5 6 2 4 5 4 3])', 3, 3, size(v,1) );
end
