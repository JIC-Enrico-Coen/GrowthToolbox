function unitnormal = unitcellnormal( m, ci )
%unitnormal = unitcellnormal( m, ci )
%   Calculate the unit normal vector to element ci of the mesh.  The length of
%   the vector is twice the area of the cell.  ci can be a vector; the
%   result will be an N*3 array.

    unitnormal = cellnormal( m, ci );
    n = sqrt( sum( unitnormal.*unitnormal, 2 ) );
    for i=1:length(ci)
        unitnormal(i,:) = unitnormal(i,:)/n(i);
    end
end
