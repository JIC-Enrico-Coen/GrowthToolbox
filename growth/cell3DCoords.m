function v = cell3DCoords( mesh, ci, bc )
%v = cell3DCoords( mesh, ci, bc )
%   Find the 3D coordinates of the point with barycentric coordinates bc in cell ci.
    coords = mesh.nodes( mesh.tricellvxs(ci,:), : );;
    v = bc * coords;
end

