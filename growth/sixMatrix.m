function M6 = sixMatrix( M3 )
% M6 = sixMatrix( M3 )
%    M3 is assumed to be a 3*3 rotation matrix.  This function returns
%    the corresponding 6*6 matrix for transforming a tensor written in
%    6-vector form.
%  NEVER USED.  Not known if this is correct regarding the issue of doubling
%  the off-diagonal elements.

    M6 = zeros(6,6);
    for i = 1:3
        M6(i,:) = row6( M3(i,:), M3(i,:) );
    end
    M6(4,:) = row6( M3(2,:), M3(3,:) );
    M6(5,:) = row6( M3(3,:), M3(1,:) );
    M6(6,:) = row6( M3(1,:), M3(2,:) );
end

function v6 = row6( v, w )
    v6 = [ v(1)*w(1), ...
           v(2)*w(2), ...
           v(3)*w(3), ...
           v(2)*w(3)+v(3)*w(2), ...
           v(3)*w(1)+v(1)*w(3), ...
           v(1)*w(2)+v(2)*w(1) ];
end
