function perFEvertex = FEToFEvertex( m, perFE )
%perFEvertex = FEToFEvertex( m, perFE )
%   Convert a value per FE to a value per FEvertex.
%   Since perFEvertex is defined at different places than perFE is,
%   there will necessarily be a certain amount of blurring involved.

%   Each vertex gets the average of the values of the FEs it is a vertex
%   of, weighted by the areas or volumes of the FEs.

    numFE = getNumberOfFEs( m );
    numFEvertex = getNumberOfVertexes( m );
    shapeFE = size(perFE);
    shapeFEvertex = [numFEvertex,shapeFE(2:end)];
    perFE = reshape( perFE, shapeFE(1), [] );
    valuesPerItem = size(perFE,2);
    
    perFEvertex = zeros(numFEvertex,valuesPerItem);
    if true
        if isVolumetricMesh( m )
            vxsPerFE = size(m.FEsets.fevxs,2);
            volPerFEvertex = sumArray( m.FEsets.fevxs, repmat( m.FEsets.fevolumes, 1, vxsPerFE ) );
            perFEvol = perFE .* repmat( m.FEsets.fevolumes, 1, valuesPerItem );

            for j=1:valuesPerItem
                perFEvertex(:,j) = sumArray( m.FEsets.fevxs, repmat( perFEvol(:,j), 1, vxsPerFE ) ) ./ volPerFEvertex;
            end
        else
            vxsPerFE = size(m.tricellvxs,2);
            areaPerFEvertex = sumArray( m.tricellvxs, repmat( m.cellareas, 1, vxsPerFE ) );
            perFEarea = perFE .* repmat( m.cellareas, 1, valuesPerItem );

            for j=1:valuesPerItem
                perFEvertex(:,j) = sumArray( m.tricellvxs, repmat( perFEarea(:,j), 1, vxsPerFE ) ) ./ areaPerFEvertex;
            end
        end
    else
        % This is about 20 times slower.
    
        for i=1:numFEvertex
            nce = m.nodecelledges{i};
            nbFEs = nce(2,:);
            nbFEs = nbFEs(nbFEs ~= 0);
            nbAreas = m.cellareas(nbFEs)/sum( m.cellareas(nbFEs) );
            for j=1:valuesPerFE
                perFEvertex(i,j) = sum( nbAreas .* perFE(nbFEs,j) );
            end
        end
    
    end

    perFEvertex = reshape( perFEvertex, shapeFEvertex );
end
