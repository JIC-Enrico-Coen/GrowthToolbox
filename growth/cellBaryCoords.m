function bc = cellBaryCoords( m, ci, v, within )
%bc = cellBaryCoords( mesh, ci, v )
%   Find the barycentric coordinates of v in triangular finite element ci.
%   v must be a single vector.

    if nargin < 4
        within = true;
    end
    if isVolumetricMesh(m)
        coords = m.FEnodes( m.FEsets.fevxs(ci,:), : );
        bc = baryCoordsN( coords, v );
    else
        coords = m.nodes( m.tricellvxs(ci,:), : );
        bc = baryCoords( coords, m.unitcellnormals(ci,:), v, within );
    end
end

