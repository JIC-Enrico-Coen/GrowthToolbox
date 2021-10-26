function plotVVLayer( m )
    if ~isfield( m, 'vvlayer' ) || isempty( m.vvlayer )
        return;
    end
    % For each wall edge, plot three parallel straight lines, and circles
    % for the interior segment ends.
    numwalls = length(m.vvlayer.cellwallindexes);
    wallends = permute( ...
                   reshape( m.nodes( m.edgeends( m.vvlayer.cellwallindexes, : )', : ), ...,
                            2, [], 3 ), ...
                   [2,3,1] );
    wallvecs = wallends(:,:,2) - wallends(:,:,1);
    wallperps = wallvecs * [ 0 1 0; -1 0 0; 0 0 1];
    wallsep = m.vvlayer.targetwallseglength * 0.5;
    wallperps = wallperps .* repmat( wallsep./sqrt( sum( wallperps.^2, 2 ) ), 1, 3 );
    h = guidata(m.pictures(1));
    %~ figure( m.pictures(1) );
    hold( h.picture, 'on' );
    for i=1:numwalls
        ei = m.vvlayer.cellwallindexes(i);
        startwall = wallends( i, :, 1 );
        endwall = wallends( i, :, 2 );
        numsegs = m.vvlayer.numedgesegments(ei);
        pts = [ linspace( startwall(1), endwall(1), numsegs+1 )', ...
                linspace( startwall(2), endwall(2), numsegs+1 )', ...
                linspace( startwall(3), endwall(3), numsegs+1 )' ];
        plotpts( h.picture, pts(2:(end-1),:), 'o' );
    end
    for vi = m.vvlayer.cellcentres'
        vxs = m.vvlayer.vertexcluster{vi};
        plotpts( h.picture, vxs, 'o' );
        nce = m.nodecelledges{vi};
        for j=1:size(vxs,1)
            ci = nce(2,j);
            ei = m.celledges( ci, m.tricellvxs( ci, : )==vi );
            vx1 = vxs(j,:);
            if j==size(vxs,1), k = 1; else k = j+1; end
            vx2 = vxs(k,:);
            numsegs = m.vvlayer.numedgesegments( ei );
            p = linspace( 0, 1, numsegs+1 )';
            p = p(2:(end-1));
            if ~isempty(p)
                plotpts( h.picture, (1-p)*vx1 + p*vx2, 'o' );
            end
        end
        plotpts( h.picture, vxs( [1:end,1], : ), '-' );
    end
    plotpts( h.picture, m.nodes, 'o' );
    hold( h.picture, 'off' );
    
    % For each wall junction, find the walls incident on it and plot the
    % required circles and lines.
    
    % For each cell centre, plot a circle there, and lines from it to all of
    % the wall segment ends.
end
