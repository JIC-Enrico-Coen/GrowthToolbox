function reloadMesh( handles, reloadtype )
    wasBusy = setGFtboxBusy( handles, true );
    startTic = startTimingGFT( handles );
    [m,ok] = leaf_reload( handles.mesh, reloadtype, 'rewrite', false );
    stopTimingGFT('leaf_reload',startTic);
    if ok
        handles = installNewMesh( handles, m );
        guidata(handles.output, handles);
    else
        queryDialog( 1, 'File not found', 'The requested stage file cannot be found.' );
    end
	setGFtboxBusy( handles, wasBusy );
end

