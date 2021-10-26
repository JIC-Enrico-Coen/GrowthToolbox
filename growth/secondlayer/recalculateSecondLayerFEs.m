function m = recalculateSecondLayerFEs( m, changedFEmap )
%m = recalculateSecondLayerFEs( m )
%   When the finite elements have changed, use the 3D coordinates of the
%   bio layer vertexes to find which FEs they are in and where within those
%   FEs.

    if nargin < 2
        changedFEmap = true( getNumberOfFEs(m), 1 );
    end

    numbiovxs = size(m.secondlayer.cell3dcoords,1);
    vxsToUpdate = find( changedFEmap( m.secondlayer.vxFEMcell ) );
%     if isVolumetricMesh(m)
%         m.secondlayer.vxBaryCoords = zeros( numbiovxs, size( m.FEsets(1).fevxs, 2 ) );
%     else
%         m.secondlayer.vxBaryCoords = zeros( numbiovxs, 3 );
%     end
    for i=1:length(vxsToUpdate)
        vx = vxsToUpdate(i);
        [ ci, bc, ~, ~ ] = findFE( m, m.secondlayer.cell3dcoords(vx,:) );
        m.secondlayer.vxFEMcell(vx) = ci;
        m.secondlayer.vxBaryCoords(vx,:) = bc;
    end
    m.secondlayer.cell3dcoords = baryToGlobalCoords( m.secondlayer.vxFEMcell, m.secondlayer.vxBaryCoords, m.FEnodes, m.FEsets.fevxs );
end
