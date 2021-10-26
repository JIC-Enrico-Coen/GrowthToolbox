function J = getMeshCellFrame( m, ci )
%J, = getMeshCellFrame( m, ci )
%   J is set to a right-handed unit basis whose first column is parallel to
%   the polarisation gradient, and whose third is parallel to the cell normal.
%   If the polarisation gradient is zero, the first column will be an
%   arbitrary unit vector perpendicular to the cell normal.

    J = getCellFrame( ...
        m.unitcellnormals(ci,:), ...
        m.gradpolgrowth(ci,:) );
end
