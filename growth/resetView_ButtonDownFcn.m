function resetView_ButtonDownFcn( hObject, eventdata )
    h = guidata( hObject );
    global gMatlabViewParams gOurViewParams
    if isempty( h.mesh )
        cp = gMatlabViewParams;
        op = gOurViewParams;
    else
        cp = h.mesh.globalProps.defaultViewParams;
        op = ourViewParamsFromCameraParams( cp );
    end
    set( h.azimuth, 'Value', -op.azimuth );
    set( h.elevation, 'Value', -op.elevation );
    set( h.roll, 'Value', -op.roll );
    attemptCommand( guidata(hObject), false, false, ...
            'plotoptions', ...
            'matlabViewParams', cp );
end
