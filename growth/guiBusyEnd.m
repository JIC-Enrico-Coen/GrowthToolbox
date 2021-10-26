function guiBusyEnd( handles, savedstate )
    setRunning( handles, savedstate.oldrunning );
    guidata(handles.GFTwindow, handles);
    if ~isempty(savedstate) && isfield( savedstate, 'oldCursor' )
        set(handles.GFTwindow,'Pointer',savedstate.oldCursor);
    end
end
