function mpc = mgenPerCell( m, mgen, cellindexes )
% Calculate the average value of the given named morphogen over a given
% biological cell.
    if ~isfield( m.secondlayer, 'cells' )
        mpc = [];
        return;
    end
    
    if ischar(mgen) || (numel(mgenName)==1)
        mgenIndex = FindMorphogenIndex( m, mgen );
        if mgenIndex==0
            mpc = [];
            return;
        end
        mgen = m.morphogens( :, mgenIndex );
    end
    
    if nargin < 3
        cellindexes = 1:length( m.secondlayer.cells );
    end
    
    mpc = zeros( length(cellindexes), 1 );
    for ci=1:length(cellindexes)
        cellindex = cellindexes(ci);
        cvxs = m.secondlayer.cells(cellindex).vxs;
        meshvxs = m.tricellvxs( m.secondlayer.vxFEMcell(cvxs), : )';
        baryvxs = m.secondlayer.vxBaryCoords( cvxs, : );
        mgenvals = reshape( mgen( meshvxs ), 3, [] )';
        mgen_perCellVx = dot( mgenvals, baryvxs, 2 );
        mpc(ci) = mean(mgen_perCellVx);
    end
end

