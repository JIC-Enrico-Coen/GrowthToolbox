function vvlayer = plotVVvalues( ax, vvlayer )
%vvlayer = plotVVvalues( ax, vvlayer )
%   Plot only the plotted quantity for each vertex of the VVlayer, assuming
%   the vertex circles and edge lines have already been drawn.

    if isempty( vvlayer )
        return;
    end
    
    allhandles = [ vvlayer.plothandles.vxvalC; vvlayer.plothandles.vxvalW; vvlayer.plothandles.vxvalM ];
    delete( allhandles(allhandles>0) );
    vvlayer.plothandles.vxvalC = [];
    vvlayer.plothandles.vxvalW = [];
    vvlayer.plothandles.vxvalM = [];
    
    MARKERSIZE = 10; % sqrt(vvlayer.mgenC(i,plotmgen))*25/maxmgensqrt
    plotmgen = lookUpVVmgens( vvlayer, vvlayer.plotoptions.morphogen );
    haveC = vvlayer.plotoptions.plotC && (plotmgen ~= 0) && any( vvlayer.mgenC(:,plotmgen) ~= 0 );
    haveW = vvlayer.plotoptions.plotW && (plotmgen ~= 0) && any( vvlayer.mgenW(:,plotmgen) ~= 0 );
    haveM = vvlayer.plotoptions.plotM && (plotmgen ~= 0) && any( vvlayer.mgenM(:,plotmgen) ~= 0 );
    
    if plotmgen ~= 0
        % maxmgensqrt = sqrt( max( [ max(vvlayer.mgenC(:,plotmgen)), max(vvlayer.mgenW(:,plotmgen)), max(vvlayer.mgenM(:,plotmgen)) ] ) );
    
        oldhold = ishold(ax);
        
        cmap = makeCmap( [1 1 1;0 1 0], 100, 1 );
        if haveC
            hC = plotColouredPoints( ax, vvlayer.vvptsC, vvlayer.mgenC(:,plotmgen), cmap, [0 max(vvlayer.mgenC(:,plotmgen))], MARKERSIZE*3 );
        end
        if haveW
            hW = plotColouredPoints( ax, vvlayer.vvptsW, vvlayer.mgenW(:,plotmgen), cmap, [], MARKERSIZE*1.5 );
        end
        if haveM
            cmap = makeCmap( [1 0 0;1 1 1;0 0 1], 100, 1 );
            hM = plotColouredPoints( ax, vvlayer.vvptsM, vvlayer.mgenM(:,plotmgen), cmap, [], MARKERSIZE );
        end
    
        hold(ax,boolchar(oldhold,'on','off'));
    end
    
    % Plot the outlines of the vertexes (by default in shades of grey).
    if haveW
        if ~isfield( vvlayer.plothandles, 'vxW' )
            vvlayer.plothandles.vxW = [];
        end
        vvlayer.plothandles.vxW = updateVertexPlot( vvlayer.plothandles.vxW, ...
            ax, vvlayer.vvptsW, MARKERSIZE*1.5, vvlayer.plotoptions.vertexcolorW );
    end
    
    if haveM
        if ~isfield( vvlayer.plothandles, 'vxM' )
            vvlayer.plothandles.vxM = [];
        end
        vvlayer.plothandles.vxM = updateVertexPlot( vvlayer.plothandles.vxM, ...
            ax, vvlayer.vvptsM, MARKERSIZE, vvlayer.plotoptions.vertexcolorM );
    end
    
    if haveC
        if ~isfield( vvlayer.plothandles, 'vxC' )
            vvlayer.plothandles.vxC = [];
        end
        vvlayer.plothandles.vxC = updateVertexPlot( vvlayer.plothandles.vxC, ...
            ax, vvlayer.vvptsC, MARKERSIZE*3, vvlayer.plotoptions.vertexcolorC );
    end
end

function h = updateVertexPlot( h, ax, data, marksize, color )
    if isempty(color) || isempty(data)
        if ishandle(h)
            delete(h);
        end
        h = [];
    elseif ishandle( h )
        set( h, ...
            'LineStyle', 'none', 'Marker', 'o', ...
            'MarkerSize', marksize, 'MarkerEdgeColor',color, ...
            'XData', data(:,1), ...
            'YData', data(:,2), ...
            'ZData', data(:,3) );
    else
        h = plotpts( ax, data, ...
            'LineStyle', 'none', 'Marker', 'o', ...
            'MarkerSize', marksize, 'MarkerEdgeColor', color );
    end
end
