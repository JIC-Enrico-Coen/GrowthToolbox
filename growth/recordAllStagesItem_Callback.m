function recordAllStagesItem_Callback( hObject, eventdata )
    handles = guidata( hObject );
    if isempty(handles.mesh)
        return;
    end
    recording = toggleCheckedMenuItem( hObject );
    handles.mesh = leaf_setproperty( handles.mesh, 'recordAllStages', recording );
    guidata( hObject, handles );
end