function a = crossproc2( b, c )
%a = crossproc2( b, c )
%   Equivalent to cross(b,c,2) where b and c are two-dimensional M*3*N
%   matrices.
%
%   See also DOTPROC1, DOTPROC2, CROSSPROC2.

    a = [ b(:,2,:).*c(:,3,:) - b(:,3,:).*c(:,2,:), ...
          b(:,3,:).*c(:,1,:) - b(:,1,:).*c(:,3,:), ...
          b(:,1,:).*c(:,2,:) - b(:,2,:).*c(:,1,:) ];
end

