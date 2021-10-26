function resultfiles = getClusterResults( pack, fetch )

    global RemoteProjectsDirectory
    
    if nargin < 1
        pack = true;
    end
    if nargin < 2
        fetch = true;
    end
    

    getClusterDetails();
    
    % Find the projects on the remote machine.
    [ok,output] = executeRemote( sprintf( 'ls -1 %s', RemoteProjectsDirectory ) );
    if ~ok
        fprintf( 1, 'No runs available:\n    %s', output );
        return;
    end
    
    output = regexprep( output, '\s+$', '' ); % Delete trailing newline.
    
    projectNames = splitString( '\s+', output );  % This assumes that spaces never occur in filenames on the remote machine.
    numprojects = length( projectNames );
    resultfiles = cell(1,numprojects);
    
    for i=1:numprojects
        projectName = projectNames{i};
        if isempty( projectName )
            continue;
        end
        
        % Read the ProjectInfo file to get the local project directory.
        remoteProjectInfoFile = clusterfullfile( RemoteProjectsDirectory, projectName, 'ClusterFiles', 'ProjectInfo.txt' );
        [ok,output] = executeRemote( sprintf( 'cat %s', remoteProjectInfoFile ), true );
        if ~ok
            fprintf( 1, 'Cannot determine local directory for project %s:\n    %s', projectName, output );
            continue;
        end
        localProjectDirectory = regexprep( output, '\s', '' );
        localRunsDir = fullfile( localProjectDirectory, 'runs' );
        [~,~,~] = mkdir( localRunsDir );
        
        remoteRunsDir = clusterfullfile( RemoteProjectsDirectory, projectName, 'runs' );
        remoteResultsfile = clusterfullfile( remoteRunsDir, 'results.mat' );
        [ok,~] = executeRemote( sprintf( 'ls -1 %s', remoteResultsfile ), true );
        if ok
            localResultsfile = fullfile( localRunsDir, 'results.mat' );
            fprintf( 1, 'Retrieving results file.\n' );
            ok = copyFileLocalRemote( localResultsfile, remoteResultsfile, '<' );
            if ~ok
                fprintf( 1, 'Copying results file back failed for project %s:\n', projectName );
                continue;
            end
            resultfiles{i} = localResultsfile;
        else
            [ok,output] = executeRemote( sprintf( 'ls -1 %s', remoteRunsDir ) );
            if ~ok
                fprintf( 1, 'No run data available for project %s:\n    %s', projectName, output );
                continue;
            end
            
            zipname = 'someruns.zip';
            if pack
                fprintf( 1, 'No results file, retrieving all data.\n' );
                fprintf( 1, 'Runs to retrieve:\n%s', output );
                fprintf( 1, 'Preparing compressed file %s\n', clusterfullfile( remoteRunsDir, zipname ) );
                [ok,output] = executeRemote( sprintf( '''cd %s; zip -r -q %s *''', remoteRunsDir, zipname ) );
                if ~ok
                    fprintf( 1, 'Compressing runs failed for project %s:\n    %s', projectName, output );
                    continue;
                end
            else
                fprintf( 1, 'Packing not requested.\n' );
            end
        
            if fetch
                % Copy the zip file to the local project runs directory.
                localZipFullPath = fullfile( localRunsDir, zipname );
                remoteZipFullPath = clusterfullfile( remoteRunsDir, zipname );
                resultfiles{i} = localZipFullPath;
                fprintf( 1, 'Copy compressed file:\n    Remote: %s\n    Local:  %s.\n', remoteZipFullPath, localZipFullPath );
                ok = copyFileLocalRemote( localZipFullPath, remoteZipFullPath, '<' );
                if ~ok
                    fprintf( 1, 'Copying compressed file back failed for project %s:\n', projectName );
                    continue;
                end
                fprintf( 1, 'Decompressing %s.\n', localZipFullPath );
                unzip( localZipFullPath, localRunsDir );
    %             delete( localZipFullPath );
            else
                fprintf( 1, 'Fetching not requested.\n' );
            end
        end
    end
end
