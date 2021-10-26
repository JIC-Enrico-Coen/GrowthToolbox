function requestStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty( handles.mesh )
        return;
    end
    [stages,ok] = askForNumlist( 'Stages to compute' );
    if ok
        fprintf( 1, 'Recomputing stages:' );
        fprintf( 1, ' %.3f', stages );
        fprintf( 1, '.\n' );
        startTic = startTimingGFT( handles );
        handles.mesh = leaf_requeststages( handles.mesh, ...
            'stages', stages );
        stopTimingGFT('leaf_requeststages',startTic);
        handles = remakeStageMenu( handles );
        guidata( handles.output, handles );
    end

