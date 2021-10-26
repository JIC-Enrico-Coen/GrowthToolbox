function J = getCellFrame( n, p )
%J = getCellFrame( n, p )
%   J is set to a right-handed unit basis whose first column is parallel to
%   the polarisation gradient P, and whose third is parallel to the cell
%   normal N.
%   If the polarisation gradient is zero, an arbitrary unit vector
%   perpendicular to the cell normal will be chosen instead of the
%   polarisation gradient.

    if (p * p') == 0
        J1 = makebasis( n, findPerpVector( n ) );
    else
        J1 = makebasis( n, p );
    end

    J = J1( :, [2 3 1] );
end
