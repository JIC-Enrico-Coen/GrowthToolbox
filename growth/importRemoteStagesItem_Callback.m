function importRemoteStagesItem_Callback( hObject, ~ )
    handles = guidata( hObject );
    if isempty(handles.mesh)
        return;
    end
    if isempty(handles.mesh.globalProps.projectdir)
        fprintf( 1, 'The mesh does not belong to a project.\n' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    [name,desc] = MoveStagesToProject( handles.mesh );
    if ~isempty(name)
        handles = guidata( hObject );
        handles.mesh.globalProps.savedrunname = name;
        handles.mesh.globalProps.savedrundesc = desc;
        guidata( hObject, handles );
        setMeshFigureTitle( handles.output, handles.mesh );
    end
    setGFtboxBusy( handles, wasBusy );
end

