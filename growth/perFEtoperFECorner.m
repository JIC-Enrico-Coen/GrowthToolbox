function perFECorner = perFEtoperFECorner( m, perFE, fes )
    vxsPerFE = getNumberOfVertexesPerFE( m );
    wholemesh = nargin < 4;
    if wholemesh
        perFECorner = reshape( repmat( reshape( perFE, 1, [] ), vxsPerFE, 1 ), [], 1 );
    else
        perFECorner = reshape( repmat( reshape( perFE(fes), 1, [] ), vxsPerFE, 1 ), [], 1 );
    end
end











