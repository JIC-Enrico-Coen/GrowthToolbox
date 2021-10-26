function bc6 = hexbc( bc, d )
%bc6 = hexbc( bc, d )
%   Return the barycentric coordinates of a hexagon centred on bc with
%   radius d.

    bc6 = normaliseBaryCoords( ...
        [bc;bc;bc;bc;bc;bc] + ...
        [ [  d  0  0 ];
          [  0 -d  0 ];
          [  0  0  d ];
          [ -d  0  0 ];
          [  0  d  0 ];
          [  0  0 -d ];
        ] )
end
    