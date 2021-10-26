function result = performDialog( dialogtitle, dialogspec )
    fig = figure( ...
        'IntegerHandle', 'on', ...
        'NumberTitle', 'on', ...
        'DockControls', 'off', ...
        'MenuBar', 'none', ...
        'BackingStore', 'off', ...
        'Resize', 'on', ...
        'HandleVisibility', 'callback', ...
        'Name', dialogtitle );
    dialogspec = convertStringsToHandles( fig, dialogspec );
    skeleton = layoutSkeleton( dialogspec, fig );
    items = layoutItem( skeleton );
    showGUIPositions( items );
    setPositionsInDialog( items );
    guidata( fig, guihandles(fig) );
    set( fig, 'Visible', 'on' );
    listGUIObjects( fig );
%     result = [];
%     return;
    uiwait(fig);
    result = [];
    if ishandle(fig)
        handles = guidata( fig );
        if isfield( handles, 'output' )
            result = handles.output;
        end
        delete(fig);
    end
end