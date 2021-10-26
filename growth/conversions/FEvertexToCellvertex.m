function perCellvertex = FEvertexToCellvertex( m, perFEvertex, method )
%perCellvertex = FEvertexToCellvertex( m, perFEvertex, method )
%   Convert a value per FEvertex to a value per Cellvertex.
%   Since perCellvertex is defined at different places than perFEvertex is,
%   there will necessarily be a certain amount of blurring involved.
%   perFEvertex can also be a morphogen index or a morphogen name.  If the
%   specified morphogen does not exist, the empty array is returned.
%
%   perFEvertex can be a matrix of any shape whose first dimension is
%   the number of FEvertexes. perCellvertex will be a matrix of corresponding
%   shape whose first dimension is the number of Cellvertexes.
%
%   This is valid for foliate and volumetric meshes.

    if nargin < 3
        method = 'mid';
    end
    
    if isVolumetricMesh(m)
        fevxs = m.FEsets(1).fevxs;
    else
        fevxs = m.tricellvxs;
    end

    numFEvertex = getNumberOfVertexes( m );
    if (size(perFEvertex,1) ~= numFEvertex) || iscell(perFEvertex) || ischar(perFEvertex)
        mgens = FindMorphogenIndex( m, perFEvertex );
        perFEvertex = m.morphogens(:,mgens);
    end
    numCellvertex = getNumberOfCellvertexes( m );
    shapeFEvertex = size(perFEvertex);
    itemshape = shapeFEvertex(2:end);
    perFEvertex = reshape( perFEvertex, numFEvertex, [] );
    valuesPerItem = size(perFEvertex,2);
    perCellvertex = zeros(numCellvertex,valuesPerItem);
    vxsPerFE = size(fevxs,2);

    fePerCellVertex = fevxs( m.secondlayer.vxFEMcell, : );  % CV * T
    perFEperCellVertex = permute( reshape( perFEvertex(fePerCellVertex',:), vxsPerFE, numCellvertex, valuesPerItem ), [2 1 3] );  % CV * VF * K
    for i=1:valuesPerItem
        perCellvertex(:,i) = reshape( sum( perFEperCellVertex(:,:,i) .* m.secondlayer.vxBaryCoords, 2 ), [], 1 );
    end

    perCellvertex = reshape( perCellvertex, [numCellvertex,itemshape] );
end
