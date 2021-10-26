function displacements = allCellFlatDisplacements( m )
%displacements = cellFlatDisplacements( normal, vxs )
%   Calculate the displacements of the vertexes of the cell from a right
%   prism.

    uppernodes = 2:2:size(m.prismnodes,1);
    semiverticals = 0.5*(m.prismnodes( uppernodes, : ) - m.prismnodes( uppernodes-1, : ));

    d1 = projectVecToLine( semiverticals( m.tricellvxs(:,1), : ), m.unitcellnormals );
    d2 = projectVecToLine( semiverticals( m.tricellvxs(:,2), : ), m.unitcellnormals );
    d3 = projectVecToLine( semiverticals( m.tricellvxs(:,3), : ), m.unitcellnormals );
    displacements = [ -d1; -d2; -d3; d1; d2; d3 ];
end
