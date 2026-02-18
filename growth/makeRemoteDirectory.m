function ok = makeRemoteDirectory( remoteDir, force )
%ok = makeRemoteDirectory( remoteDir, force )
%   Create a directory on the remote machine (the details of which are
%   stored in global variables not referenced here).
%
%   This procedure maintains a list of all the directories it has created.
%   If FORCE is false, it first checks that list to see if it has already
%   created the directory. If it has, it returns true but does not try to
%   create it again. Note that it does not check to see if the directory
%   still exists.
%
%   The default value of FORCE is false.
%
%   The list of created directories is stored in the global variable
%   RemoteDirectoriesCreated.

    global RemoteDirectoriesCreated
    if nargin < 2
        force = false;
    end
    
    if ~force
        if isempty( RemoteDirectoriesCreated )
            RemoteDirectoriesCreated = {};
        end
        finddir = find( strcmp( RemoteDirectoriesCreated, remoteDir ), 1 );
        if any( finddir )
            ok = true;
            return;
        end
    end
    
    timedFprintf( 'Making remote directory "%s".\n', remoteDir );
    ok = executeRemote( sprintf( 'mkdir -p ''%s''', remoteDir ) );
    if ok
        RemoteDirectoriesCreated = [ RemoteDirectoriesCreated, { remoteDir } ];
    end
end
