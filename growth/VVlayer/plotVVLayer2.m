function vvlayer = plotVVLayer2( ax, vvlayer, varargin )
%vvlayer = plotVVLayer2( ax, vvlayer, ... )
%   Plot the vvlayer VVLAYER on the given axes AX.  Remaining arguments
%   specify plotting options.  Any plotting options that are specified will
%   be stored into vvlayer.plotoptions.  VVLAYER is not otherwise modified.
%   For the complete list of plotting options, see plotVVLayerOptions.
%
%   See also: plotVVLayerOptions.

    if isempty( vvlayer )
        return;
    end
    
    vvlayer = plotVVLayerOptions( vvlayer, varargin{:} );
    vvlayer.ax = ax;
    vvlayer.plothandles.vxvalC = [];
    vvlayer.plothandles.vxvalW = [];
    vvlayer.plothandles.vxvalM = [];
    plotC = vvlayer.plotoptions.plotC;
    plotM = vvlayer.plotoptions.plotM;
    plotW = vvlayer.plotoptions.plotW;

%{
     vcells: {1x27 cell}
        vvc: [148x4 double]
       vvcc: [81x6 double]
     ecells: {1x27 cell}
     vvptsC: [27x3 double]
     vvptsW: [321x3 double]
    vvptsWi: [321x4 double]
     vvptsM: [558x3 double]
    vvptsMi: [558x3 double]
     edgeCM: [558x2 double]
     edgeMM: [558x2 double]
     edgeWW: [402x2 double]
     edgeWM: [558x2 double]
%}
    
    % Plot lines joining vertexes.
    oldhold = ishold(ax);
    hold on;
    if plotC
        vvlayer.plothandles.edgeCM = plotIndexedLines( vvlayer.edgeCM, vvlayer.vvptsC, vvlayer.vvptsM, 'Parent', ax, 'Color', vvlayer.plotoptions.edgecolorCM );
    end
    if plotM
        vvlayer.plothandles.edgeMM = plotIndexedLines( vvlayer.edgeMM, vvlayer.vvptsM, vvlayer.vvptsM, 'Parent', ax, 'Color', vvlayer.plotoptions.edgecolorMM );
    end
    if plotW
        vvlayer.plothandles.edgeWW = plotIndexedLines( vvlayer.edgeWW, vvlayer.vvptsW, vvlayer.vvptsW, 'Parent', ax, 'Color', vvlayer.plotoptions.edgecolorWW );
    end
    if plotM
        vvlayer.plothandles.edgeWM = plotIndexedLines( vvlayer.edgeWM, vvlayer.vvptsW, vvlayer.vvptsM, 'Parent', ax, 'Color', vvlayer.plotoptions.edgecolorWM );
    end
    
    vvlayer = plotVVvalues( ax, vvlayer );
    
    if vvlayer.plotoptions.drawvvcellpolarity
        polarity = vvlayer.cellpolarity;
        havepol = any(polarity ~= 0,2);
        if any(havepol)
            cellradius = zeros(0,length(vvlayer.cellM));
            polsize = sqrt(sum(polarity.^2,2));
            maxpolsize = max(polsize);
            for i=1:length(vvlayer.cellM)
                %if havepol(i)
                    cm = vvlayer.cellM{i};
                    mpts = vvlayer.vvptsM(cm,:);
                    cellradius(i) = max( max(mpts,[],1) - min(mpts,[],1) )/2;
                %end
            end
            cellrad = min(cellradius(havepol));
            polarity = polarity*(cellrad/maxpolsize);

            polarity = polarity( havepol, : );
            centres = vvlayer.vvptsC(havepol,:);
            myquiver3(centres,polarity,[0 0 1],0.3,[],1,1,'Color', 'k', 'LineWidth', 3, 'Parent', ax );
    %         quiver3( ax, centres(:,1), centres(:,2), centres(:,3), ...
    %                  polarity(:,1), polarity(:,2), polarity(:,3), '-b', 'LineWidth', 3 );
        end
    end
    
    hold(ax,boolchar(oldhold,'on','off'));
    return;
     
     
     
    % For each wall edge, plot three parallel straight lines, and circles
    % for the interior segment ends.
    numwalls = length(vvlayer.cellwallindexes);
    wallends = permute( ...
                   reshape( m.nodes( m.edgeends( vvlayer.cellwallindexes, : )', : ), ...,
                            2, [], 3 ), ...
                   [2,3,1] );
    % wallvecs = wallends(:,:,2) - wallends(:,:,1);
    % wallperps = wallvecs * [ 0 1 0; -1 0 0; 0 0 1];
    % wallsep = vvlayer.targetwallseglength * 0.5;
    % wallperps = wallperps .* repmat( wallsep./sqrt( sum( wallperps.^2, 2 ) ), 1, 3 );
    h = guidata(m.pictures(1));
    % figure( m.pictures(1) );
    hold( h.picture, 'on' );
    for i=1:numwalls
        ei = vvlayer.cellwallindexes(i);
        startwall = wallends( i, :, 1 );
        endwall = wallends( i, :, 2 );
        numsegs = vvlayer.numedgesegments(ei);
        pts = [ linspace( startwall(1), endwall(1), numsegs+1 )', ...
                linspace( startwall(2), endwall(2), numsegs+1 )', ...
                linspace( startwall(3), endwall(3), numsegs+1 )' ];
        plotpts( h.picture, pts(2:(end-1),:), 'o' );
    end
    for vi = vvlayer.cellcentres'
        vxs = vvlayer.vertexcluster{vi};
        plotpts( h.picture, vxs, 'o' );
        nce = m.nodecelledges{vi};
        for j=1:size(vxs,1)
            ci = nce(2,j);
            ei = m.celledges( ci, m.tricellvxs( ci, : )==vi );
            vx1 = vxs(j,:);
            if j==size(vxs,1), k = 1; else k = j+1; end
            vx2 = vxs(k,:);
            numsegs = vvlayer.numedgesegments( ei );
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
