function handles = clearImageData( handles )
    handles.mouseDownInHistory = 0;
    handles.mousetracking = 0;
    handles.mouseStartPos = [0 0];
    handles.historyImageOffset = [0 0];
    handles.maxHistoryOffset = [0 0];
    if isfield( handles, 'historyImage' )
        handles = rmfield( handles, 'historyImage' );
    end
    rotate3d( handles.picture, 'off' );
    zoom( handles.picture, 'off' );
    pan( handles.picture, 'off' );
    set( handles.rotateToggle, 'Value', 0 );
    set( handles.rotuprightToggle, 'Value', 0 );
    set( handles.zoomToggle, 'Value', 0 );
    set( handles.panToggle, 'Value', 0 );
    set( handles.azimuth, 'Value', 45 );
    set( handles.elevation, 'Value', -33.75 );
    set( handles.roll, 'Value', 0 );
end
