function perCellvertex = FEToCellvertex( m, perFE, method )
%perCellvertex = FEToCellvertex( m, perFE, method )
%   Convert a value per FE to a value per Cellvertex.
%   Since perCellvertex is defined at different places than perFE is,
%   there will necessarily be a certain amount of blurring involved.
%
%   perFE can be a matrix of any shape whose first dimension is
%   the number of FEs. perCellvertex will be a matrix of corresponding
%   shape whose first dimension is the number of Cellvertexes.
%
%   This is currently valid for foliate meshes only.

%     if isVolumetricMesh(m)
%         perCellvertex = [];
%         return;
%     end

    if nargin < 3
        method = 'mid';
    end
    
    numFE = getNumberOfFEs( m );
    numCellvertex = getNumberOfCellvertexes( m );
    shapeFE = size(perFE);
    itemshape = shapeFE(2:end);
    perFE = reshape( perFE, numFE, [] );

    perCellvertex = perFE( m.secondlayer.vxFEMcell, : );

    perCellvertex = reshape( perCellvertex, [numCellvertex,itemshape] );
end
