function perCell = perFEVertexToPerCell( m, perFEvertex )
%percell = perFEVertexToPerCell( m, pervertex )
%   Convert a per-FE-vertex quantity to a per-cell quantity.

    perCell = FEvertexToCell( m, perFEvertex );
%     return;
%     
%     
%     
%     numcells = length(m.secondlayer.cells);
%     percell = zeros( numcells, 1 );
%     for ci=1:numcells
%         secondlayer_vxs = m.secondlayer.cells(ci).vxs;
%         femCells = m.secondlayer.vxFEMcell( secondlayer_vxs );
%         femBCs = m.secondlayer.vxBaryCoords( secondlayer_vxs, : );
%         femvxs = m.tricellvxs( femCells, : );
%         percellvertexPerFEVx = reshape( perFEvertex( femvxs' ), 3, [] )';
%         percellvertex = sum( percellvertexPerFEVx .* femBCs, 2 );
%         percell(ci) = sum( percellvertex, 1 ) / length( secondlayer_vxs );
%     end
end
