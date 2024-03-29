function [mesh,vxparents,feparents] = thicken2Dto3D( mesh2d, axisdivs, height, fetype, subdivision )
%[mesh,vxparents,feparents] = thicken2Dto3D( mesh2d, axisdivs, height, fetype, subdivision )
%
%   mesh2d is a 2d mesh in the XY plane, with fields nodes and tricellvxs.
%
%   This procedure constructs a volumetric mesh obtained by replicating
%   mesh2d axisdivs+1 times along the Z axis, to the given height, and
%   constructing pentahedral elements joining the layers.

    if nargin < 5
        subdivision = 14;
    end

    mesh2d = safermfield( mesh2d, 'globalProps' ); % Some methods of creating 2D meshes make this field, which is not relevant here.
    a = findFEareas( mesh2d );
    
    num2dnodes = size( mesh2d.nodes, 1 );
    num2dfaces = size( mesh2d.tricellvxs, 1 );
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
    
    vxparents1 = repmat( (1:num2dnodes)', axisdivs+1, 1 );
    feparents = repmat( (1:getNumberOfFEs(mesh2d))', axisdivs, 1 );

    oldnumvxs = size( newm.FEnodes, 1 );
    switch fetype
        case 'T4Q'
            [newm,vxparents,feparents1] = convertP6toT4Q( newm, 'subdivision', subdivision );
            vxparents3 = vxparents;
            vxparents3(vxparents3(:,1) ~= 0,1) = vxparents1( vxparents3(vxparents3(:,1) ~= 0,1) );
            vxparents = vxparents3;
            feparents2 = feparents(feparents1);
            feparents = feparents2;
        otherwise
            vxparents = [ (1:oldnumvxs)', zeros( oldnumvxs, 2 ) ];
    end

    mesh = completeVolumetricMesh( newm );
    
    % For each new vertex, find all its neighbours. These should all have
    % non-zero ring indexes, whose values are two integers differing by 2.
    % The ring index of the vertex is the integer between them.
end
