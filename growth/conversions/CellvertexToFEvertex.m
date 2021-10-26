function perFEvertex = CellvertexToFEvertex( m, perCellvertex, method )
%perFEvertex = CellvertexToFEvertex( m, perCellvertex, method )
%   Convert a value per Cellvertex to a value per FEvertex.
%   Since perFEvertex is defined at different places than perCellvertex is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perCellvertex can be a matrix of any shape whose first dimension is
%   the number of Cellvertexes. perFEvertex will be a matrix of corresponding
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
    
    perCell = CellvertexToCell( m, perCellvertex, method );
    perFEvertex = CellToFEvertex( m, perCell, method );
end
