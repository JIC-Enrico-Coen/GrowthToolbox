function exists = existsRemoteFile( filename )
% Determine whether the given filename exists on the remote machine. If it
% is a relative path (as will normally be the case) it is interpreted
% relative to the remote user's home directory.
%
% It makes the test by attempting an ls -d command for the filename. This
% fails if the file does not exist (or if there is any other problem, but
% we ignore that).

    global DryRun

    if DryRun
        % Force the dry run to go through the motions of creating the
        % required remote file.
        
        exists = false;
    else
        exists = executeRemote( sprintf( 'ls -d ''%s''', filename ), true );
    end
end

