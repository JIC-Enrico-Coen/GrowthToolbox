function perFE = CellToFE( m, perCell, method )
%perFE = CellToFE( m, perCell, method )
%   Convert a value per Cell to a value per FE.
%   Since perFE is defined at different places than perCell is,
%   there will necessarily be a certain amount of blurring involved.
%   perCell can also be a cell factor index or name.  If the
%   specified cell factor does not exist, the empty array is returned.
%
%   perCell can be a matrix of any shape whose first dimension is
%   the number of Cells. perFE will be a matrix of corresponding
%   shape whose first dimension is the number of FEs.
%
%   This is currently valid for foliate meshes only.

    if isVolumetricMesh(m)
        perFE = [];
        return;
    end

    if nargin < 3
        method = 'mid';
    end
    
    numCell = getNumberOfCells( m );
    if (size(perCell,1) ~= numCell) || iscell(perCell) || ischar(perCell)
        cellvalues = FindCellValueIndex( m, perCell );
        perCell = m.morphogens(:,cellvalues);
    end
    numCellvertex = getNumberOfCellvertexes( m );
    numFE = getNumberOfFEs( m );
    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        perFE = zeros( numFE, 1 );
        return;
    end
    
    shapeCell = size(perCell);
    itemshape = shapeCell(2:end);
    perCell = reshape( perCell, numCell, [] );
    valuesPerItem = size(perCell,2);
    perFE = zeros(numFE,valuesPerItem);

    perCellVx = CellToCellvertex( m, perCell, method );
    
    numPerFE = zeros( numFE, 1 );
    for i=1:numCellvertex
        fei = m.secondlayer.vxFEMcell(i);
        perFE(fei,:) = perFE(fei,:) + perCellVx(i,:);
        numPerFE(fei) = numPerFE(fei)+1;
    end
    
    perFE = perFE ./ repmat( numPerFE, 1, valuesPerItem );
    
    missingFEs = find(numPerFE==0);
    for i=missingFEs(:)'
        cells = findCellForPoint( m, m.nodes(m.tricellvxs(i,:),:) );
        perFE(i,:) = sum(perCell( cells, : ),1)/length(cells);
    end

    perFE = reshape( perFE, [numFE,itemshape] );
end
