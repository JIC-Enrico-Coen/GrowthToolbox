function a = findFEareas( m )
%m = findFEareas( m )
%   Calculate the area of every cell of the mesh.

    a = findtriangleareas( m.nodes, m.tricellvxs );
end

