function m = plotHighlightedVertexes( m, theaxes )
    if ~isfield( m.selection, 'highlightedVxList' )
        return;
    end
    if isempty( m.selection.highlightedVxList )
        visibleHilitedVxList = [];
    elseif islogical( m.selection.highlightedVxList )  % Obsolete, highlightedVxList should always be a list of indexes.
        visibleHilitedVxMap = m.visible.nodes & m.selection.highlightedVxList;
        visibleHilitedVxList = find( visibleHilitedVxMap );
    else
        visibleHilitedVxList = m.selection.highlightedVxList( m.visible.nodes( m.selection.highlightedVxList ) );
    end
    if isempty( visibleHilitedVxList )
        if ~isempty( m.plothandles.HLvertexes )
            if ishandle( m.plothandles.HLvertexes )
                delete( m.plothandles.HLvertexes );
            end
            m.plothandles.HLvertexes = [];
        end
    else
        if m.plotdefaults.thick
            ni = visibleHilitedVxList*2;
            ni = [(ni-1);ni];
            points = m.prismnodes( ni, : );
        else
            points = m.nodes( visibleHilitedVxList, : );
        end
        xvals = points(:,1);
        yvals = points(:,2);
        zvals = points(:,3);
        if isempty( m.plothandles.HLvertexes ) || ~ishandle( m.plothandles.HLvertexes )
            m.plothandles.HLvertexes = line( xvals, yvals, zvals, ...
                'Parent', theaxes, 'Color', 'k', 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 30, ...
                'ButtonDownFcn', @GFtboxGraphicClickHandler );
            m.plothandles.HLvertexes.Tag = 'HLvertexes';
        else
            set( m.plothandles.HLvertexes, 'Xdata', xvals, 'Ydata', yvals, 'Zdata', zvals );
        end
        setPlotHandleData( m, 'HLvertexes', 'vxs', visibleHilitedVxList, 'ButtonDownFcn', @doMeshClick );
    end
end
