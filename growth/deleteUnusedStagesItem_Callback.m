function deleteUnusedStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty( handles.mesh )
        return;
    end
	if isempty(handles.mesh.globalProps.projectdir)
        complain( 'No project.' );
        return;
    end
    startTic = startTimingGFT( handles );
    handles.mesh = leaf_deletestages( handles.mesh, 'stages', false, 'times', true );
    stopTimingGFT('leaf_deletestages',startTic);
    handles = remakeStageMenu( handles );
    guidata( handles.output, handles );

