function coords = cellcoords( mesh, ci )
%coords = cellcoords( mesh, ci )
%   Return the coordinates of the three vertexes of triangular cell ci.
    coords = mesh.nodes( mesh.tricellvxs(ci,:), : );
  % error('cellcoords obsolete');
end
