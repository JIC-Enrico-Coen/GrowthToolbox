function m = convert3vectorTo22matrix( v )
%m = convert3vectorTo22matrix( v )
%   Convert a tensor in 3-vector form to a symmetric 2x2 matrix.
%   v may be an N*3 matrix representing N tensors, and m will be 2x2xN.

    symmetrycount = 2;
    v(:,3) = v(:,3)/symmetrycount;
%     m = [ v(1), v(3); ...
%           v(3), v(2) ];
      
    m = reshape( v(:,[1 3 3 2])', 2, 2, size(v,1) );
end
