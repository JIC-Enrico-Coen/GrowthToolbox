function displacements = cellFlatDisplacements( vxs, normal )
%displacements = cellFlatDisplacements( normal, vxs )
%   Calculate the displacements of the vertexes of the cell from a right
%   prism.

    d1 = projectVecToLine( 0.5*(vxs(4,:) - vxs(1,:)), normal );
    d2 = projectVecToLine( 0.5*(vxs(5,:) - vxs(2,:)), normal );
    d3 = projectVecToLine( 0.5*(vxs(6,:) - vxs(3,:)), normal );
    displacements = [ -d1; -d2; -d3; d1; d2; d3 ];
end
