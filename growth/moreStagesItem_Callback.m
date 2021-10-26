function moreStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty( handles.mesh )
        return;
    end
    [stages,ok] = askForNumlist( 'Stages to compute' );
    if ok
        fprintf( 1, 'Recomputing stages:' );
        fprintf( 1, ' %.3f', stages );
        fprintf( 1, '.\n' );
        setRunning( handles, 1 );
        handles.mesh = leaf_requeststages( handles.mesh, ...
            'stages', stages );
        handles = remakeStageMenu( handles );
        handles.mesh = leaf_recomputestages( handles.mesh, ...
            'stages', stages, ...
            'plot', 1 );
        guidata( handles.output, handles );
        setRunning( handles, 0 );
    end

