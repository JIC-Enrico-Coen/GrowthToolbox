function saveExperimentStagesItem_Callback(hObject, eventdata)
    handles = guidata( hObject );
    if isempty(handles.mesh)
        return;
    end
    if isempty(handles.mesh.globalProps.modelname)
        fprintf( 1, 'The mesh does not belong to a project.\n' );
        return;
    end
    % Get a name and description.
    % Copy all current stage files to runs/(name)/meshes
    wasBusy = setGFtboxBusy( handles, true );
    defaultname = [ 'run', ... % handles.mesh.globalProps.modelname, ...
                    '_', datestr(clock,'yyyymmdd_HHMMSS') ];
  % defaultdesc = datestr(clock,'yyyy mmm dd HH:MM:SS');
  % [name,desc] = askForNameDesc( defaultname, defaultdesc );
    dialogresult = performRSSSdialogFromFile( ...
                findGFtboxFile( 'guilayouts/saverunlayout.txt' ), ...
                struct( 'name', defaultname ), ...
                [], ...
                @(h)setGFtboxColourScheme( h, handles ) );
              % struct( 'name', defaultname, 'desc', defaultdesc ) );
    if isempty(dialogresult)
        name = [];
    else
        name = dialogresult.name;
    end
    desc = name;
    if ~isempty(name)
        attemptCommand( handles, false, false, ...
            'saverun', 'name', name, 'desc', desc, 'verbose', true );
        handles = guidata( hObject );
        setMeshFigureTitle( handles.output, handles.mesh );
    end
%     if ~ok
%         fprintf( 1, 'Saving run %s (%s) failed.\n', name, desc );
%     end
    setGFtboxBusy( handles, wasBusy );
end
