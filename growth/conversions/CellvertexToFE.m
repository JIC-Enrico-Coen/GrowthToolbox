function perFE = CellvertexToFE( m, perCellvertex, method )
%perFE = CellvertexToFE( m, perCellvertex, method )
%   Convert a value per Cellvertex to a value per FE.
%   Since perFE is defined at different places than perCellvertex is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perCellvertex can be a matrix of any shape whose first dimension is
%   the number of Cellvertexes. perFE will be a matrix of corresponding
%   shape whose first dimension is the number of FEs.
%
%   This is currently valid for foliate meshes only.

    if nargin < 3
        method = 'mid';
    end
    
    perCell = CellvertexToCell( m, perCellvertex, method );
    perFE = CellToFE( m, perCell, method );
end
