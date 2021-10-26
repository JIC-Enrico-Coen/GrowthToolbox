function [m,celllayer] = makesecondlayeruniversal3D( m, celldiameter )
    % Find surface mesh of m.
    [s,embedding] = extractSurface( m );
    embedding.facelocalvxs = [ embedding.facelocalvxs, 10 - sum(embedding.facelocalvxs,2) ];
    celllayer = makeCellsOnMesh( s.nodes, s.tricellvxs, [], celldiameter );
    numbiovxs = length(celllayer.vxFEMcell);
    foo = sub2ind([numbiovxs,4], repmat((1:numbiovxs)', 1, 3 ), embedding.facelocalvxs(celllayer.vxFEMcell,1:3) );
    
    newbcs = zeros( size( celllayer.vxBaryCoords, 1 ), 4 );
    newbcs(foo) = celllayer.vxBaryCoords;
    vxFEMface = embedding.faceSurfaceToVolIndex( celllayer.vxFEMcell );
    newVxFEMcell = m.FEconnectivity.facefes( vxFEMface );
    
    pts = baryToGlobalCoords( newVxFEMcell, newbcs, m.FEnodes, m.FEsets.fevxs );
    pts2 = baryToGlobalCoords( celllayer.vxFEMcell, celllayer.vxBaryCoords, s.nodes, s.tricellvxs );
    % pts and pts2 should be equal to within rounding error.
    
    celllayer.vxFEMcell = newVxFEMcell;
    celllayer.vxBaryCoords = newbcs;
    
    
    
    % s.nodes and m.FEnodes(embedding.vertexSurfaceToVolIndex,:) are identical.
    % foo = s.nodes - m.FEnodes(embedding.vertexSurfaceToVolIndex,:);

    
    
    
    xxxx = 1;
    
    
    
    % celllayer indexes into the extracted surface, not the original mesh.
    % It needs to be transformed to do the latter.
    
    
    

    % We need to know for each triangle, which tetrahedral FE it belongs
    % to, which vertexes of the FE the triangle's vertexes correspond to,
    % and which is the fourth vertex.  This information needs to be
    % returned by extractSurface.
    
    
    
    


% Code to be revised for volumetric meshes:

    m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    m.secondlayer = setFromStruct( m.secondlayer, celllayer );
    numcells = size(celllayer.cell3dcoords,1);
    m.secondlayer.cellcolor = ...
        randcolor( numcells, ...
             m.globalProps.colorparams(1,[1 2 3]), ...
             m.globalProps.colorparams(1,[4 5 6]) );
    m.secondlayer.surfaceVertexes = true( length(m.secondlayer.vxFEMcell), 1 );
end
