function perCell = FEvertexToCell( m, perFEvertex, method, whichcells )
%perCell = FEvertexToCell( m, perFEvertex, method, whichcells )
%   Convert a value per FEvertex to a value per Cell.
%   Since perCell is defined at different places than perFEvertex is,
%   there will necessarily be a certain amount of blurring involved.
%   perFEvertex can also be a morphogen index or a morphogen name.  If the
%   specified morphogen does not exist, the empty array is returned.
%
%   perFEvertex can be a matrix of any shape whose first dimension is
%   the number of FEvertexes. perCell will be a matrix of corresponding
%   shape whose first dimension is the number of Cells.
%
%   This is currently valid for foliate meshes only.

%     if isVolumetricMesh(m)
%         perCell = [];
%         perCellVertex = perFEVertexToPerCellVertex( m, s_divarea_p );
%         perCell = perCellVertexToPerCell( m, perCellVertex );
%         return;
%     end
    
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
    
    if wholemesh
        perCellvertex = FEvertexToCellvertex( m, perFEvertex, method );
        perCell = CellvertexToCell( m, perCellvertex, method );
    else
        numCell = getNumberOfCells( m );
        if nargin < 3
            whichcells = 1:numCell;
        elseif islogical( whichcells )
            whichcells = find(whichcells);
        end
        whichcells = whichcells(:);

        perCellvertex = FEvertexToCellvertex( m, perFEvertex, method );
        perCell = CellvertexToCell( m, perCellvertex, method, whichcells );
    end
end
