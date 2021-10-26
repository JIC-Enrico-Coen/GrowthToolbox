function perCellvertex = CellToCellvertex( m, perCell, method )
%perCellvertex = CellToCellvertex( m, perCell, method )
%   Convert a value per Cell to a value per Cellvertex.
%   Since perCellvertex is defined at different places than perCell is,
%   there will necessarily be a certain amount of blurring involved.
%   perCell can also be a cell factor index or name.  If the
%   specified cell factor does not exist, the empty array is returned.
%
%   perCell can be a matrix of any shape whose first dimension is
%   the number of Cells. perCellvertex will be a matrix of corresponding
%   shape whose first dimension is the number of Cellvertexes.

%     if isVolumetricMesh(m)
%         perCellvertex = [];
%         return;
%     end

    if nargin < 3
        method = 'mid';
    end
    
    numCell = getNumberOfCells( m );
    if (size(perCell,1) ~= numCell) || iscell(perCell) || ischar(perCell)
        cellvalues = FindCellValueIndex( m, perCell );
        perCell = m.morphogens(:,cellvalues);
    end
    numCellvertex = getNumberOfCellvertexes( m );
    shapeCell = size(perCell);
    itemshape = shapeCell(2:end);
    perCell = reshape( perCell, numCell, [] );
    valuesPerItem = size(perCell,2);

    % Can combiningFunctionIndexed handle this?
    % Probably not, because the indexing is ragged.
    switch method
        case 'min'
            perCellvertex = inf(numCellvertex,valuesPerItem);
            for ci=1:length(m.secondlayer.cells)
                cellvxs = m.secondlayer.cells(ci).vxs;
                perCellvertex(cellvxs,:) = min( perCellvertex(cellvxs,:), repmat( perCell(ci,:), length(cellvxs), 1 ) );
            end
            perCellvertex(isinf(perCellvertex)) = 0;
        case 'max'
            perCellvertex = -inf(numCellvertex,valuesPerItem);
            for ci=1:length(m.secondlayer.cells)
                cellvxs = m.secondlayer.cells(ci).vxs;
                perCellvertex(cellvxs,:) = max( perCellvertex(cellvxs,:), repmat( perCell(ci,:), length(cellvxs), 1 ) );
            end
            perCellvertex(isinf(perCellvertex)) = 0;
        otherwise
            % Do we want to weight by the area of the cells?  Or by the
            % area attributable to each vertex?
            perCellvertex = zeros(numCellvertex,valuesPerItem);
            cellspervertex = zeros( length(m.secondlayer.vxFEMcell), 1 );
            for ci=1:length(m.secondlayer.cells)
                cellvxs = m.secondlayer.cells(ci).vxs;
                perCellvertex(cellvxs,:) = perCellvertex(cellvxs,:) + repmat( perCell(ci,:), length(cellvxs), 1 );
                cellspervertex(cellvxs) = cellspervertex(cellvxs) + 1;
            end
            perCellvertex = perCellvertex./repmat(cellspervertex,1,valuesPerItem);
            perCellvertex(~isfinite(perCellvertex),:) = 0;
    end

    perCellvertex = reshape( perCellvertex, [numCellvertex,itemshape] );
end
