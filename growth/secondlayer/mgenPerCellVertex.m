function mpv = mgenPerCellVertex( m, mgen, cvxs )
% Calculate the value of the given named morphogen at the given vertexes of
% the cellular layer.

    if isempty( m.secondlayer.cells )
        mpv = [];
        return;
    end
    
    if ischar(mgen) || (numel(mgen)==1)
        mgenIndex = FindMorphogenIndex( m, mgen );
        if mgenIndex==0
            mpv = [];
            return;
        end
        mgen = m.morphogens(:,mgenIndex);
    end
    
    if nargin < 3
        cvxs = 1:size( m.secondlayer.vxFEMcell, 1 );
    end
    
    meshvxs = m.tricellvxs( m.secondlayer.vxFEMcell(cvxs), : )';
    baryvxs = m.secondlayer.vxBaryCoords( cvxs, : );
    mgenvals = reshape( mgen(meshvxs), 3, [] )';
    mpv = dot( mgenvals, baryvxs, 2 );
end

