function m = makemultilayer( m, layers, thickness )
%m = makemultilayer( m, layers, thickness )
%   Given a mesh for which m.nodes is defined, make it into a multilayer
%   mesh with the given number of layers.  If layers==1, then a hybrid mesh
%   is returned, otherwise a volumetric mesh.

% Requires the following fields of m to already be present:
%   nodes
%   tricellvxs

    global FE_P6 FE_T3

    pts = m.nodes;
    tri = int32( m.tricellvxs );
    
    numnodes = size(pts,1);
    numcells = size(tri,1);
    offsets = linspace( -thickness/2, thickness/2, layers+1 );
    
    nodenormals = vertexNormals( pts, tri );
    
    aa = reshape( nodenormals', [], 1 ) * offsets;
    bb = repmat( reshape( pts', [], 1 ), 1, layers+1 );
    allpts = reshape( aa + bb, 3, [] )';
    
    
    
    
    
    
%     offsets = repmat( offsets, numnodes, 1 );
%     allpts = repmat( pts, layers+1, 1 );
%     allpts(:,3) = allpts(:,3) + offsets(:);
    triP6 = [ tri, tri+numnodes ];
    trioffsets = repmat( int32(0:(layers-1))*numnodes, numcells, 1 );
    trioffsets = repmat( trioffsets(:), 1, size(triP6,2) );
    alltri = repmat( triP6, layers, 1 ) + trioffsets;
    
    m.FEnodes = allpts;
    m.FEsets = struct( 'fe', FE_P6, 'fevxs', alltri );
    if isfield( m, 'unitcellnormals' ) && (layers > 1)
        m.unitcellnormals = repmat( m.unitcellnormals, layers, 1 );
    end
    m.globalProps.hybridMesh = layers==1;
    if m.globalProps.hybridMesh
%         m.FEnodes = [ m.FEnodes; m.nodes ];
%         m.FEsets(2) = struct( 'fe', FE_T3, 'fevxs', tri + 2*numnodes );
    else
        m = safermfield( m, 'nodecelledges', 'cellareas' );
    end
    m = safermfield( m, 'nodes', 'prismnodes', 'tricellvxs' );
end


