function perCell = FEToCell( m, perFE, method )
%perCell = FEToCell( m, perFE, method )
%   Convert a value per FE to a value per Cell.
%   Since perCell is defined at different places than perFE is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perFE can be a matrix of any shape whose first dimension is
%   the number of FEs. perCell will be a matrix of corresponding
%   shape whose first dimension is the number of Cells.
%
%   This is currently valid for foliate meshes only.

    if isVolumetricMesh(m)
        perCell = [];
        return;
    end

    if nargin < 3
        method = 'mid';
    end
    
    numFE = getNumberOfFEs( m );
    numCell = getNumberOfCells( m );
    shapeFE = size(perFE);
    itemshape = shapeFE(2:end);
    perFE = reshape( perFE, numFE, [] );
    valuesPerItem = size(perFE,2);
    perCell = zeros(numCell,valuesPerItem);

    for ci=1:numCell
        secondlayer_vxs = m.secondlayer.cells(ci).vxs;
        femCells = m.secondlayer.vxFEMcell( secondlayer_vxs );
        percellvertex = perFE( femCells, : );
        perCell(ci,:) = sum( percellvertex, 1 ) / length( secondlayer_vxs );
    end

    perCell = reshape( perCell, [numCell,itemshape] );
end
