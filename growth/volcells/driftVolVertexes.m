function m = driftVolVertexes( m )
% NOT USED
% INCOMPLETE
% PErHAPS SUPERSEDED BY THE VERTEX CREEP CODE IN THE I.F.

    [~,~,m.volcells] = validVolcells( m.volcells );
    numvxs = getNumberOfVolVertexes( m.volcells );
    numedges = getNumberOfVolEdges( m.volcells );
    
    vxedges = sortrows( [ [ m.volcells.edgevxs(:,1), (1:numedges)' ]; [ m.volcells.edgevxs(:,2), (1:numedges)' ] ] );
    [w,len,starts,ends] = runlengths( vxedges(:,1) );
    
    vxdisplacements = shiftdim( sum( reshape( m.displacements( m.FEsets.fevxs( m.volcells.vxfe, : )', : ), 4, numvxs, 3 ) ...
                                       .* m.volcells.vxbc', ...
                                     1 ), ...
                                1 );
    oldedgevecs = m.volcells.vxs3d( m.volcells.edgevxs(:,2), : ) - m.volcells.vxs3d( m.volcells.edgevxs(:,1), : );
    oldedgelengths = sqrt( sum( oldedgevecs.^2, 2 ) );
    edgechangevecs = vxdisplacements( m.volcells.edgevxs(:,2), : ) - vxdisplacements( m.volcells.edgevxs(:,1), : );
    
    driftdistance = zeros( numvxs, 1 );
    driftvec = zeros( numvxs, 3 );
    for vi=1:numvxs
        thisvxedges = vxedges( starts(vi):ends(vi), 2 );
        vxneighbours = m.volcells.edgevxs( thisvxedges, : );
        vxneighbours = unique( vxneighbours(vxneighbours ~= vi) );
        if m.volcells.atcornervxs(vi)
            continue;
        elseif m.volcells.onedgevxs(vi)
            vxneighbours = vxneighbours( m.volcells.onedgevxs(vxneighbours) );
        elseif m.volcells.surfacevxs(vi)
            vxneighbours = vxneighbours( m.volcells.surfacevxs(vxneighbours) );
        end
        nbs3d = m.volcells.vxs3d( vxneighbours, : );
        c = mean( nbs3d, 1 );
        errvec = c - m.volcells.vxs3d;
        dist = norm(errvec);
        nbvecs = m.volcells.vxs3d( vi, : ) - m.volcells.vxs3d( vxneighbours, : );
        nbreldisplacements = vxdisplacements( vxneighbours, : ) - vxdisplacements( vi, : );
        % Need to calculate the ratio between movement of vi along errvec
        % and shrinkage of each neighbour vector.
        
        
        
        
    end
    
    for vi=1:numvxs
        if driftdistance(vi) > 0
            [ ci, bc, bcerr, abserr, ishint ] = findFE( m, m.volcells.vxs3d(vi,:), 'hint', m.volcells.vxfe(vi) );
            m.volcells.vxfe(vi,1) = ci;
            m.volcells.vxbc(vi,:) = bc;
        end
    emd
end



