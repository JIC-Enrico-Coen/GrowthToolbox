function theta = surfaceangle( a, b, n )
%theta = surfaceangle( a, b, n )
%   A and B are vectors that are close to lying on a surface near a point
%   whose surface normal is N.  Project A and B onto the tangent plane at
%   N, and calculate the angle between the projected vectors A' and B'.
%
%   The result is an angle in the range -pi ... pi, negative if the set
%   [a',b',n] is left-handed, positive if right-handed.
%
%   A, B, and N can be N*3 matrices.  Theta will then be an N*1 vector of
%   angles.

    dims = size(a,2);
    
    % Normalise n.
    n = n./repmat( sqrt( sum( n.^2, 2 ) ), 1, dims );
    
    % Project a and b to the plane normal to n.
    a = a - n.*repmat( sum( a.*n, 2 ), 1, dims );
    b = b - n.*repmat( sum( b.*n, 2 ), 1, dims );
    
    % Calculate the angles.
    theta = vecangle( a, b, n );
end
