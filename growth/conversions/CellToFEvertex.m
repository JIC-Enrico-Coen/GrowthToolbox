function perFEvertex = CellToFEvertex( m, perCell, method )
%perFEvertex = CellToFEvertex( m, perCell, method )
%   Convert a value per Cell to a value per FEvertex.
%   Since perFEvertex is defined at different places than perCell is,
%   there will necessarily be a certain amount of blurring involved.
%   perCell can also be a cell factor index or name.  If the
%   specified cell factor does not exist, the empty array is returned.
%
%   perCell can be a matrix of any shape whose first dimension is
%   the number of Cells. perFEvertex will be a matrix of corresponding
%   shape whose first dimension is the number of FEvertexes.
%
%   This is currently valid for foliate meshes only.

    if isVolumetricMesh(m)
        perFEvertex = [];
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
    numFEvertex = getNumberOfVertexes( m );
    shapeCell = size(perCell);
    itemshape = shapeCell(2:end);
    perCell = reshape( perCell, numCell, [] );
    valuesPerItem = size(perCell,2);
    perFEvertex = zeros(numFEvertex,valuesPerItem);

    if isVolumetricMesh(m) || ~hasNonemptySecondLayer(m)
        perFEvertex = zeros( getNumberOfVertexes(m), 1 );
        return;
    end
    
    perCellvertex = CellToCellvertex( m, perCell, method );
    
    numPerFEvx = zeros( numFEvertex, 1 );
    for i=1:numCellvertex
        fei = m.secondlayer.vxFEMcell(i);
        bcs = m.secondlayer.vxBaryCoords(i,:)';
        fevxsi = m.tricellvxs(fei,:);
        perFEvertex(fevxsi,:) = perFEvertex(fevxsi,:) + bcs*perCellvertex(i,:);
        numPerFEvx(fevxsi) = numPerFEvx(fevxsi) + bcs;
    end
    perFEvertex = perFEvertex./repmat(numPerFEvx,1,valuesPerItem);
    
    missingFEvxs = find(numPerFEvx==0);
    if ~isempty(missingFEvxs)
        cells = findCellForPoint( m, m.nodes(missingFEvxs,:) );
        perFEvertex(missingFEvxs,:) = perCell( cells, : );
    end

    perFEvertex = reshape( perFEvertex, [numFEvertex,itemshape] );
end
