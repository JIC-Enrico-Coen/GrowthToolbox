function newg = dilateSubstance( mesh, u, g )
%function newg = dilateSubstance( mesh, u, g )
%   Given a set of vertex displacements u and a vector g of the
%   concentration of a substance at each vertex, calculate the
%   concentration at each vertex after performing the displacements.

    numnodes = size(mesh.nodes,1);
    numcells = size(mesh.tricellvxs,1);
    dfsPerVertex = 3;
    vxPerCell = 6;
    numGaussPoints = 6;

    dilation = zeros(size(g,1)*2,1);
    numdilations = zeros( numnodes, 1 );
    delta_g = zeros(vxPerCell,1);
    
    for ci=1:numcells
        trivxs = mesh.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        cellvxCoords = mesh.prismnodes( prismvxs, : )';
        N = shapeN( mesh.globalProps.gaussInfo.points );
        NGNg = zeros( dfsPerVertex, vxPerCell, vxPerCell );
        for gi=1:numGaussPoints
            J = PrismJacobian( cellvxCoords, mesh.globalProps.gaussInfo.points(:,gi) );
            gNGlobal = inv(J)' * mesh.globalProps.gaussInfo.gradN(:,:,gi);
            for vi=1:vxPerCell
                NGNg(:,:,vi) = NGNg(:,:,vi) + gNGlobal * N(vi,gi);
            end
        end
        %NGNg
        
        for vi=1:vxPerCell
            delta_g(vi) = sum(sum( u(prismvxs,:)' .* NGNg(:,:,vi) ));
        end
        
        dilation(prismvxs) = dilation(prismvxs) + delta_g;
        numdilations(trivxs) = numdilations(trivxs) + 1;
    end
    dilation = dilation/numGaussPoints;
    %dilateSubstance_dilation = dilation'
    % In the next line, the multiplication by 3 instead of division by 2 is
    % to correct a suspected missing factor of 6.  Without this, the
    % dilution rate is far smaller than it should be; with it, it is
    % precisely accurate for a uniformly growing surface.
    dilationPerTriVx = sum( reshape( dilation, 2, numnodes ), 1 )*3;%/2;
    newg = g ./ (1.0+dilationPerTriVx'./numdilations);
    %dilateSubstance_newg = newg'
end
