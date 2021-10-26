function d = dilations( m, u )
%function d = dilations( m, u )
%   Given a set of vertex displacements u, calculate the
%   dilution at each vertex after performing the displacements.

    numnodes = size(m.nodes,1);
    numcells = size(m.tricellvxs,1);
    dfsPerVertex = 3;
    vxPerCell = 6;
    numGaussPoints = 6;

    dilation = zeros(size(m.prismnodes,1),1);
    numdilations = zeros( numnodes, 1 );
    delta_g = zeros(vxPerCell,1);
    
    for ci=1:numcells
        trivxs = m.tricellvxs(ci,:);
        prismvxs = [ trivxs*2-1, trivxs*2 ];
        cellvxCoords = m.prismnodes( prismvxs, : )';
        N = shapeN( m.globalProps.gaussInfo.points );
        NGNg = zeros( dfsPerVertex, vxPerCell, vxPerCell );
        for gi=1:numGaussPoints
            J = PrismJacobian( cellvxCoords, m.globalProps.gaussInfo.points(:,gi) );
            gNGlobal = inv(J)' * m.globalProps.gaussInfo.gradN(:,:,gi);
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
    d = (1./(1.0+dilationPerTriVx'./numdilations));
end
