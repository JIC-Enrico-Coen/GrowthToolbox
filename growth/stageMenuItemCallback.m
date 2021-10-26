function stageMenuItemCallback( hObject, eventdata )
    % Find and load the state corresponding to the menu item
    handles = guidata( hObject );
    if isempty( handles.mesh )
        fprintf( 1, 'No mesh.\n' );
        return;
    end
    wasBusy = setGFtboxBusy( handles, true );
    t = get( hObject, 'Tag' );
    if strcmp(t,'itemStage_initial')
        stage = 'restart';
        stageexists = true;
    else
        stagelabel = get( hObject, 'Label' );
        stageexists = (~isempty( stagelabel )) && (stagelabel(1) ~= '(');
        stage = stageTagToString( t );
    end
    if stageexists
        reloadMesh( handles, stage );
    else
        % Find latest stage before.
        stagetime = stageStringToReal( stage );
        [chosenStage,chosenTime] = latestComputedStageBefore( handles.stagesMenu, stage );
        if ~isempty(chosenTime)
            % If currentmesh is between that stage and the requested stage,
            if (chosenTime < handles.mesh.globalDynamicProps.currenttime) ...
                    && (handles.mesh.globalDynamicProps.currenttime <= stagetime)
                % Current mesh is between that stage and the requested stage.
                % Recompute from current mesh.
            else
                % Load chosenStage and recompute from there.
                stagesMenu = handles.stagesMenu;
                reloadMesh( handles, chosenStage );
                handles = guidata( stagesMenu );
            end
            fprintf( 1, 'Recomputing stage %.3f from %.3f.\n', ...
                stage, handles.mesh.globalDynamicProps.currenttime );
            setRunning( handles, 1 );
            startTic = startTimingGFT( handles );
            handles.mesh = leaf_recomputestages( handles.mesh, ...
                'stages', stagetime, ...
                'plot', 1 );
            stopTimingGFT('leaf_recomputestages',startTic);
            setRunning( handles, 0 );
        end
    end
	setGFtboxBusy( handles, wasBusy );
end
