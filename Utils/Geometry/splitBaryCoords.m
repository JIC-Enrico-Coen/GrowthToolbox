function [cell,bc] = splitBaryCoords( bc, femCell, newFemCell, splitv1, splitv2 )
%bc = splitBaryCoords( bc, femCell, newFemCell, splitv1, splitv2 )
%   bc is the barycentric coordinates of a point in the cell FEMCELL, which
%   has just been split, the added cell being NEWFEMCELL.  The edge
%   that was split has endpoints SPLITV1 and SPLITV2 relative to the old
%   cell, where these are indexes in the range 1:3.
%   Calculate the new barycentric coordinates of the same point, and its
%   cell index.
%
%   ONLY USED IN splitFEMcell, WHICH IS NEVER USED.

    % Determine which half it's in.
    test = bc( [splitv1, splitv2] );
    if test(1) > test(2)
        % It's in the old cell.
        cell = femCell;
        bc( [splitv1, splitv2] ) = [ test(1)-test(2), 2*test(2) ];
    else
        % It's in the new cell.
        cell = newFemCell;
        bc( [splitv1, splitv2] ) = [ 2*test(1), test(2)-test(1) ];
    end
end
