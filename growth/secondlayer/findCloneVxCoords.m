function c = findCloneVxCoords( m, vxs, mode )
%mesh = calcFEMcoords( mesh, vxs, mode )
%   Calculate the 3D coordinates of a list of clone vertexes.
%   If mode==0, the calculation is done on the mid-plane of the FEs.
%   If mode==-1 it is done on the A side, and if mode==1, the B side.

    full3d = usesNewFEs( m );
    if nargin < 2
        vxs = 1:length( m.secondlayer.vxFEMcell );
    end
    
    if full3d
        c = baryToGlobalCoords( ...
                m.secondlayer.vxFEMcell(vxs(:)), ...
                m.secondlayer.vxBaryCoords(vxs(:),:), ...
                m.FEnodes, ...
                m.FEsets.fevxs );
    else
        if nargin < 3
            mode = 0;
        end
        switch mode
            case -1
                nodes = m.prismnodes( 2:2:size(m.nodes,1), : );
            case 1
                nodes = m.prismnodes( 1:2:(size(m.nodes,1)-1), : );
            otherwise
                nodes = m.nodes;
        end
        c = baryToGlobalCoords( ...
                m.secondlayer.vxFEMcell(vxs(:)), ...
                m.secondlayer.vxBaryCoords(vxs(:),:), ...
                nodes, ...
                m.tricellvxs );
    end
end
