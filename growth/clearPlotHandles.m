function m = clearPlotHandles( m )
%m = clearPlotHandles( m )
%   Delete all of the plot handles and clear the plothandles structure.

    global gPlotHandles
    
    fns = fieldnames( m.plothandles );
    for i=1:length(fns)
        fn = fns{i};
        hh = m.plothandles.(fn);
        hh = hh( ishandle(hh) );
        hh = hh(hh ~= 0);
        delete( hh );
    end
    m.plothandles = gPlotHandles;
    for i=1:length(m.pictures)
        ax = m.pictures(i);
        if ishghandle( ax )
            delete( get( ax, 'Children' ) );
        end
    end
    if ~isempty( m.pictures )
        h = guidata(m.pictures(1));
        if isfield( h, 'pictureBackground' )
            delete( get( h.pictureBackground, 'Children' ) );
        end
    end
end
