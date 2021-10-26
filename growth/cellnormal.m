function normal = cellnormal( mesh, ci )
%normal = cellnormal( mesh, ci )
%   Calculate the normal vector to element ci of the mesh.  The length of
%   the vector is twice the area of the cell.  ci can be a vector; the
%   result will be an N*3 array.

    normal = zeros(length(ci),3);
    for i=1:length(ci)
        normal(i,:) = trinormal( mesh.nodes( mesh.tricellvxs( ci(i), : ), : ) );
    end
end
