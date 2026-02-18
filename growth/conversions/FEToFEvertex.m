function perFEvertex = FEToFEvertex( m, perFE, method )
%perFEvertex = FEToFEvertex( m, perFE, method )
%   Convert a value per FE to a value per FEvertex.
%   Since perFEvertex is defined at different places than perFE is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perFE can be a matrix of any shape whose first dimension is
%   the number of FEs. perFEvertex will be a matrix of corresponding
%   shape whose first dimension is the number of FEvertexes.
%
%   This works for both foliate and volumetric meshes.
%
%   The method parameter is not implemented.  This function always uses
%   averaging to obtain the per-vertex values.

%   Each vertex gets the average of the values of the FEs it is a vertex
%   of, weighted by the areas or volumes of the FEs.
%
%   The METHOD argument is not implemented. If it were, it would operate in
%   the same way as for related functions such as perVertexToperFE.
%   Instead, the calculation dome by this function is as if METHOD were
%   always 'mid'.

    if nargin < 3
        method = 'mid';
    end
    cf = combiningFunctionIndexed( method );  % NOT USED.
    
    numFE = getNumberOfFEs( m );
    numFEvertex = getNumberOfVertexes( m );
    shapeFE = size(perFE);
    itemshape = shapeFE(2:end);
    perFE = reshape( perFE, numFE, [] );
    valuesPerItem = size(perFE,2);
    
    perFEvertex = zeros(numFEvertex,valuesPerItem);
    perFEvertex1 = zeros(numFEvertex,valuesPerItem);
    if true
        if isVolumetricMesh( m )
            vxsPerFE = size(m.FEsets.fevxs,2);
%             measurePerFEvertex1 = cf( m.FEsets.fevxs, repmat( m.FEsets.fevolumes, 1, vxsPerFE ) );
            measurePerFEvertex = sumArray( m.FEsets.fevxs, repmat( m.FEsets.fevolumes, 1, vxsPerFE ) );
            perFEvol = perFE .* repmat( m.FEsets.fevolumes, 1, valuesPerItem );

            % Can this use weightedAverageArray?
            %   weightedAverageArray( m.FEsets.fevxs, perFE(:,j), m.FEsets.fevolumes )
            for j=1:valuesPerItem
                perFEvertex(:,j) = sumArray( m.FEsets.fevxs, repmat( perFEvol(:,j), 1, vxsPerFE ) ) ./ measurePerFEvertex;
            end
        else
            vxsPerFE = size(m.tricellvxs,2);

            % Can this use weightedAverageArray?
            if strcmp( method, 'mid' )
                measurePerFEvertex = sumArray( m.tricellvxs, repmat( m.cellareas, 1, vxsPerFE ) );
                perFEarea = perFE .* repmat( m.cellareas, 1, valuesPerItem );
                for j=1:valuesPerItem
                    perFEvertex(:,j) = sumArray( m.tricellvxs, repmat( perFEarea(:,j), 1, vxsPerFE ) ) ./ measurePerFEvertex;
                end
            else
                for j=1:valuesPerItem
                    perFEvertex(:,j) = cf( m.tricellvxs, repmat( perFE(:,j), 1, vxsPerFE ) );
                end
            end
        end
    else
        % This is equivalent but about 20 times slower, and is only valid
        % for foliate meshes.
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

    perFEvertex = reshape( perFEvertex, [numFEvertex,itemshape] );
end
