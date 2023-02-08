function fns = mesh3DFaceNormals( m, faces )
    if nargin < 2
        facevxs = m.FEconnectivity.faces;
    else
        facevxs = m.FEconnectivity.faces( faces, : );
    end
    fns = trinormals( m.FEnodes, facevxs );
end
