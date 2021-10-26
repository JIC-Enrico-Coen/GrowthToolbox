function savedstate = guiBusyStart( handles )
    savedstate.oldCursor = get(handles.GFTwindow,'Pointer');
    set(handles.GFTwindow,'Pointer','watch');
    savedstate.oldrunning = setRunning( handles, 1 );
end
