function recomputeStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty(handles.mesh)
        return;
    end
	if isempty(handles.mesh.globalProps.projectdir)
        complain( 'No project.' );
        return;
	end
    if get( handles.runFlag, 'Value' )
        simRunningDialog( 'Cannot recompute stages while simulation is running.' );
        return;
    end
    setRunning( handles, 1 );
    stages = getAllStageTimes( handles.stagesMenu );
    startTic = startTimingGFT( handles );
    handles.mesh = leaf_recomputestages( handles.mesh, ...
        'stages', stages, ...
        'plot', 1 );
    stopTimingGFT('leaf_recomputestages',startTic);
    guidata( handles.output, handles );
    setRunning( handles, 0 );
end
    
