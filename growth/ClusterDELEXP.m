function ClusterDELEXP( projects )
%ClusterDELEXP(projectname)
%   Delete the runs directory for the given projects on the cluster.

global RemoteProjectsDirectory

    if ischar( projects )
        projects = { projects };
    end
    
    for i=1:length(projects)
        projectname = projects{i};
        if ~isSafeFilename( projectname )
            continue;
        end
        remotefullpath = clusterfullfile( RemoteProjectsDirectory, projectname, 'runs' );
        command = sprintf( 'rm -rf ''%s''', remotefullpath );
        [~,~,co] = executeRemote( command );
        if isempty(co)
            fprintf( 1, 'Deleted remote runs directory %s\n', remotefullpath );
        else
            fprintf( 1, 'Failed to delete remote runs directory %s:\n%s', remotefullpath, co );
        end
    end
end

