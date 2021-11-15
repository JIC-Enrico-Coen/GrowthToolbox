function recentprojectsMenuItemCallback(hObject, eventdata)
    handles = guidata( hObject );
    ud = get( hObject, 'Userdata' );
    fprintf( 1, 'recentprojectsMenuItemCallback %s\n', ud.modeldir );
    [parentdir,modelname,modelext] = fileparts( ud.modeldir );
    modelname = [modelname,modelext]; % In case the model name contains a ".".
    startTic = startTimingGFT( handles );
    [m,ok] = leaf_loadmodel( handles.mesh, modelname, parentdir, 'soleaccess', true );
    stopTimingGFT('leaf_loadmodel',startTic);
    if ok && ~isempty(m)
%         unselectProjectMenu( handles );
%         selectProjectMenu( hObject, true );
        handles = installNewMesh( handles, m );
        updateProjectMenuHighlights( handles, ud.modeldir );
        guidata(hObject, handles);
    else
        beep;
    end
end
