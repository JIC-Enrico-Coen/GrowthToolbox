function mesh = thicken2Dto3D( mesh2d, axisdivs, height, fetype )
%mesh = thicken2Dto3D( mesh2d, axisdivs, height )
%
%   mesh2d is a 2d mesh in the XY plane, with fields nodes and tricellvxs.
%
%   This procedure constructs a volumetric mesh obtained by replicating
%   mesh2d axisdivs+1 times along the Z axis, to the given height, and
%   constructing pentahedral elements joining the layers.

    mesh = [];
    mesh2d = safermfield( mesh2d, 'globalProps' ); % Some methods of creating 2D meshes make this field, which is not relevant here.
    a = findFEareas( mesh2d );
    
    num2dnodes = size(mesh2d.nodes,1);
    mesh2d.nodes = repmat( mesh2d.nodes, axisdivs+1, 1 );
    
    heights = (0:axisdivs)*(height/axisdivs) - height/2;
    mesh2d.nodes(:,3) = reshape( repmat( heights, num2dnodes, 1 ), [], 1 );
    
    num2dtris = size(mesh2d.tricellvxs,1);
    p6vxs = repmat( mesh2d.tricellvxs, axisdivs+1, 1 );
    offsets = (0:axisdivs)*num2dnodes;
    
    p6vxs = p6vxs + repmat( reshape( repmat( offsets, num2dtris, 1 ), [], 1 ), 1, 3 );
    
    p6vxs = [ p6vxs(1:(end-num2dtris),:), p6vxs((num2dtris+1):end,:) ];
    
    newm.FEnodes = mesh2d.nodes;
    layervolumes = a*height/axisdivs;
    newm.FEsets = struct( 'fe', FiniteElementType.MakeFEType('P6'), ...
                          'fevxs', p6vxs, ...
                          'fevolumes', repmat( layervolumes, axisdivs, 1 ) );
                      
    newm.globalDynamicProps.currentVolume = sum( newm.FEsets.fevolumes );

    switch fetype
        case 'T4Q'
            newm = convertP6toT4Q( newm );
        otherwise
    end

    mesh = completeVolumetricMesh( newm );

end
