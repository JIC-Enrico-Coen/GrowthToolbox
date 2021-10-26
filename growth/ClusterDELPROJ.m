function ClusterDELPROJ( projects )
%ClusterDELPROJ(projectname)
%   Delete a set of projects from the remote machine, including auxiliary files
%   outside the project directory. This assumes that the project is at top
%   level in the remote user's home directory.

global RemoteProjectsDirectory

    if ischar( projects )
        projects = { projects };
    end
    
    for i=1:length(projects)
        projectname = projects{i};
        if ~isSafeFilename( projectname )
            continue;
        end
        remotefullpath = clusterfullfile( RemoteProjectsDirectory, projectname );
        command = sprintf( 'rm -rf ''%s''', remotefullpath );
        [~,co1] = executeRemote( command );
        command = sprintf( 'rm -f ''%s''*', projectname );
        [~,co2] = executeRemote( command );
        if isempty(co1) && isempty(co2)
            fprintf( 1, 'Deleted remote project directory %s\n', remotefullpath );
        else
            fprintf( 1, 'Failed to delete remote project directory %s:\n%s', remotefullpath, join( {co1, co2}, ['----' newline] ) );
        end
    end
end