function handles = makeNewProject( handles, newProjectName )
    if ~handles.havemesh, return; end
    if get( handles.runFlag, 'Value' )
        beep;
        fprintf( 1, 'Cannot make a new project while simulation in progress.\n' );
        return;
    end
    handles = closeProject( handles );
    handles.projectIndex = handles.projectIndex + 1;
    if nargin >= 2
        handles.mesh.projectName = newProjectName;
        newProjectDirectory = fullfile( handles.allProjectsDirectory, newProjectName );
    elseif isfield( handles.mesh, 'projectName' )
        newProjectName = handles.mesh.projectName;
        newProjectDirectory = fullfile( handles.allProjectsDirectory, newProjectName );
    else
        while 1
            newProjectName = sprintf( 'P_%04d', handles.projectIndex );
            newProjectDirectory = fullfile( handles.allProjectsDirectory, newProjectName );
            if ~exist( newProjectDirectory, 'file' )
                break;
            end
            handles.projectIndex = handles.projectIndex+1;
        end
        handles.mesh.projectName = newProjectName;
    end

    if handles.havemesh
        % Create the directory.
        [success,msg,msgid] = mkdir( newProjectDirectory );

        if success
            fprintf( 1, 'New project %s created in %s.\n', ...
                newProjectName, handles.allProjectsDirectory );
            handles.mesh.projectDirectory = newProjectDirectory;
            handles.mesh = saveAsNewNode( handles.mesh );
        else
            handles.mesh = rmfield( handles.mesh, 'projectName' );
            fprintf( 1, 'Cannot create project directory %s in %s.\n',...
                newProjectName, handles.allProjectsDirectory );
        end
    end
    guidata( handles.output, handles );
end
