function perCellvertex = perFEVertexToPerCellVertex( m, perFEvertex )
%perCellvertex = perVertexToPerCell( m, perFEvertex )
%   Convert a per-FE-vertex quantity to a per-cell-vertex quantity.

    if size(perFEvertex,1)==1
        perFEvertex = perFEvertex(:);
    end

    if isVolumetricMesh(m)
        fePerCellVertex = m.FEsets(1).fevxs( m.secondlayer.vxFEMcell, : );  % CV * T
    else
        fePerCellVertex = m.tricellvxs( m.secondlayer.vxFEMcell, : );  % CV * T
    end
    perFEperCellVertex = perFEvertex(fePerCellVertex);  % CV * T
    perCellvertex = sum( perFEperCellVertex .* m.secondlayer.vxBaryCoords, 2 );
end
