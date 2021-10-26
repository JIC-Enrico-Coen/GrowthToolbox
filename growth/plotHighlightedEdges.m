function m = plotHighlightedEdges( m )
    visibleSeams = m.visible.edges & m.seams;
    eis = find( visibleSeams );
    if isempty(eis)
        if ishandle( m.plothandles.HLedges )
            delete( m.plothandles.HLedges );
        end
        m.plothandles.HLedges = [];
        return;
    end

    h = guidata( m.pictures(1) );
    theaxes = h.picture;
    he = m.edgeends( eis, : );
    if m.plotdefaults.thick
        he = he*2;
        if m.plotdefaults.decorateAside
            startnodecoords = m.prismnodes( he(:,1)-1, : );
            endnodecoords = m.prismnodes( he(:,2)-1, : );
        else
            startnodecoords = m.prismnodes( he(:,1), : );
            endnodecoords = m.prismnodes( he(:,2), : );
        end
    else
        startnodecoords = m.nodes( he(:,1), : );
        endnodecoords = m.nodes( he(:,2), : );
    end
    xvals = [ startnodecoords(:,1)'; endnodecoords(:,1)' ];
    yvals = [ startnodecoords(:,2)'; endnodecoords(:,2)' ];
    zvals = [ startnodecoords(:,3)'; endnodecoords(:,3)' ];
    [xvals, yvals, zvals] = combineLines( xvals, yvals, zvals );
    if isempty( m.plothandles.HLedges ) || ~ishandle( m.plothandles.HLedges )
        m.plothandles.HLedges = line( xvals, yvals, zvals, ...
            'Parent', theaxes, ...
            'Color', m.plotdefaults.seamlinecolor, ...
            'LineStyle', '-', ...
            'LineWidth', m.plotdefaults.seamlinesize, ...
            ... % 'LineSmoothing', m.plotdefaults.linesmoothing, ...  % LineSmoothing is deprecated.
            'Marker', 'none', ...
            'ButtonDownFcn', @GFtboxGraphicClickHandler );
    else
        set( m.plothandles.HLedges, 'Xdata', xvals, 'Ydata', yvals, 'Zdata', zvals );
    end
    setPlotHandleData( m, 'HLedges', 'edges', eis, 'ButtonDownFcn', @doMeshClick );
end
