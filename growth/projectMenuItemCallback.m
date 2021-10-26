function projectMenuItemCallback(hObject, eventdata)
fprintf( 1, 'projectMenuItemCallback %s\n', get( hObject, 'Label' ) );
    ud = get( hObject, 'UserData' );
    handles = guidata( hObject );
    makeDefaultThumbnail( handles.mesh );
    if ud.readonly && isempty( handles.userProjectsDir )
        complain( 'You cannot open a system project until you have defined a user projects directory.\n' );
        return;
    end
    m = [];
    if ud.readonly
        motifsDir = fullfile( handles.userProjectsDir, 'Motifs' );
        [ok,msg,~] = mkdir( motifsDir );
        if ~ok
            complain( '%s: Unable to create Motifs folder in your projects folder %s.\n    %s\n', ...
                mfilename(), handles.userProjectsDir, msg );
        else
            [projectdir,modelname] = dirparts( ud.modeldir );
            startTic = startTimingGFT( handles );
            [m,ok] = leaf_loadmodel( handles.mesh, modelname, projectdir, ...
                'copydir', motifsDir );
            stopTimingGFT('leaf_loadmodel',startTic);
        end
    else
        [projectdir,modelname] = dirparts( ud.modeldir );
        startTic = startTimingGFT( handles );
        [m,ok] = leaf_loadmodel( handles.mesh, modelname, projectdir );
        stopTimingGFT('leaf_loadmodel',startTic);
        if ~ok
            beep;
        end
    end
    if ok && ~isempty(m)
%         unselectProjectMenu( handles );
%         selectProjectMenu( hObject, true );
        handles = installNewMesh( handles, m );
        %updateProjectMenuHighlights( handles, ud.modeldir );
        guidata(hObject, handles);
    end

