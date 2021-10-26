function deleteAllStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty( handles.mesh )
        return;
    end
	if isempty(handles.mesh.globalProps.projectdir)
        complain( 'No project.' );
        return;
    end
    deleteTimes = false;
    deleteStages = false;
    after = -Inf;
    switch get( hObject, 'Tag' )
        case 'deleteStagesAndTimesItem'
            deleteTimes = true;
            deleteStages = true;
        case 'deleteAllStagesItem'
            deleteStages = true;
        case 'deleteLaterStagesItem'
            deleteStages = true;
            after = handles.mesh.globalDynamicProps.currenttime + handles.mesh.globalProps.timestep*1e-5;
        case 'deleteUnusedStagesItem'
            deleteTimes = true;
    end
    if deleteStages
        % Get confirmation.
        if deleteTimes
            answer = queryDialog( {'Yes','No'}, '', 'Delete stage files and times?' );
        else
            answer = queryDialog( {'Yes','No'}, '', 'Delete stage files?' );
        end
        if answer ~= 1
            return;
        end
    end
    startTic = startTimingGFT( handles );
    handles.mesh = leaf_deletestages( handles.mesh, 'stages', true, 'times', deleteTimes, 'after', after );
    stopTimingGFT('leaf_deletestages',startTic);
    handles = remakeStageMenu( handles );
    setMeshFigureTitle( handles.output, handles.mesh );
    guidata( handles.output, handles );
end
