function a = crossproc1( b, c )
%a = crossproc1( b, c )
%   Equivalent to cross(b,c,1) where b and c are two-dimensional 3*N
%   matrices.
%
%   See also DOTPROC1, DOTPROC2, CROSSPROC2.

    a(:,1) = [ b(2,:).*c(3,:) - b(3,:).*c(2,:), ...
               b(3,:).*c(1,:) - b(1,:).*c(3,:), ...
               b(1,:).*c(2,:) - b(2,:).*c(1,:) ];
end

