function perCell = CellvertexToCell( m, perCellvertex, method, whichcells )
%perCell = CellvertexToCell( m, perCellvertex, method, whichcells )
%   Convert a value per Cellvertex to a value per Cell.
%   Since perCell is defined at different places than perCellvertex is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perCellvertex can be a matrix of any shape whose first dimension is
%   the number of Cellvertexes. perCell will be a matrix of corresponding
%   shape whose first dimension is the number of Cells.
%
%   This is currently valid for foliate meshes only.

    if isVolumetricMesh(m)
        perCell = [];
        return;
    end
    
    % Do we want to weight by the area of the cells?  Or by the
    % area attributable to each vertex?
    if nargin < 3
        method = 'mid';
        wholemesh = true;
    elseif ~ischar(method)
        whichcells = method;
        method = 'mid';
        wholemesh = false;
    else
        wholemesh = nargin < 4;
    end
    
    numCellvertex = getNumberOfCellvertexes( m );
    numCell = getNumberOfCells( m );

    if wholemesh
        whichcells = 1:numCell;
    elseif islogical( whichcells )
        whichcells = find(whichcells);
    end
    whichcells = whichcells(:);
    numCellsNeeded = length( whichcells );

    shapeCellvertex = size(perCellvertex);
    itemshape = shapeCellvertex(2:end);
    perCellvertex = reshape( perCellvertex, numCellvertex, [] );
    valuesPerItem = size(perCellvertex,2);
    perCell = zeros(numCellsNeeded,valuesPerItem);

    NEW_METHOD = false;
    
    if NEW_METHOD
        cf = combiningFunction( method, 1 );
        for i=1:numCellsNeeded
            ci = whichcells(i);
            secondlayer_vxs = m.secondlayer.cells(ci).vxs;
            perCell(i,:) = cf( perCellvertex(secondlayer_vxs,:) );
        end
    else
        switch method
            case 'min'
                for i=1:numCellsNeeded
                    ci = whichcells(i);
                    secondlayer_vxs = m.secondlayer.cells(ci).vxs;
                    perCell(i,:) = min( perCellvertex(secondlayer_vxs,:), [], 1 );
                end
            case 'max'
                for i=1:numCellsNeeded
                    ci = whichcells(i);
                    secondlayer_vxs = m.secondlayer.cells(ci).vxs;
                    perCell(i,:) = max( perCellvertex(secondlayer_vxs,:), [], 1 );
                end
            otherwise
                for i=1:numCellsNeeded
                    ci = whichcells(i);
                    secondlayer_vxs = m.secondlayer.cells(ci).vxs;
                    perCell(i,:) = sum( perCellvertex(secondlayer_vxs,:), 1 ) / length( secondlayer_vxs );
                end
        end
    end

    perCell = reshape( perCell, [numCellsNeeded,itemshape] );
end
