function ok = copyFileLocalRemote( localfile, remotefile, direction, move, ignoreerrors )
%ok = copyFileLocalRemote( localfile, remotefile, direction, move )
%   Copy a file between the local machine and the remote machine, using the
%   scp command. The remote filename must be relative to the remote user's
%   home directory. The local filename may be relative or absolute in the
%   normal way.  If DIRECTION is '>' the file is copied from the local
%   machine to the remote machine. If it is '<', it is copied from the
%   remote machine to the local machine. If MOVE is true, then if the copy
%   is successful, the source file will then be deleted. MOVE is only
%   implemented for local-to-remote copies of a single file. For any other
%   sort of copy it will be ignored.
%
%   MOVE defaults to false.

    global DryRun

    global RemoteUserName ClusterName
    getClusterDetails();
    
    if (nargin < 4) || isempty( move )
        move = false;
    end
    if (nargin < 5) || isempty( ignoreerrors )
        ignoreerrors = false;
    end
    
%     pscpcommand = sprintf( '%spscp%s', pathstring );
    scpcommand = 'scp';
    fullremotefile = sprintf( '%s@%s:%s', RemoteUserName, ClusterName, remotefile );

    switch direction
        case '>'
            sourcefile = localfile;
            targetfile = fullremotefile;
        case '<'
            sourcefile = fullremotefile;
            targetfile = localfile;
        otherwise
            error( '%s: The direction argument must be present and be either ''>'' or ''<''.', mfilename() );
    end

    copyCommand =      makeScpCommand( scpcommand, sourcefile, targetfile );
    copyCommand_safe = makeScpCommand( scpcommand, sourcefile, targetfile );
    
    if DryRun
        fprintf( 1, 'DRY RUN: %s: About to %s %s to %s\n', mfilename, boolchar( move, 'move', 'copy' ), sourcefile, targetfile );
        ok = true;
    else
        fprintf( 1, '%s: About to %s %s to %s\n', mfilename, boolchar( move, 'move', 'copy' ), sourcefile, targetfile );

        [status,commandoutput] = system( copyCommand );
        ok = status==0;
        logClusterCommand( copyCommand_safe, boolchar( ok, 'Success', commandoutput ) );

        if ok
            if move
                if direction=='>'
                    delete(localfile);
                    DD=dir(localfile);
                    if ~isempty(DD)
                        fprintf( 1, '%s: Requested deletion of %s failed.\n', mfilename(), localfile );
                    end
                else
                    fprintf( 1, '%s: Copy successful. Deletion not supported for remote-to-local copies.\n', mfilename() );
                end
            else
                fprintf( 1, '%s: Copy successful.\n', mfilename() );
            end
        elseif ignoreerrors
            fprintf( 1, '%s: Copy failed.\n    Command: %s\n    Output: %s\n', mfilename(), copyCommand_safe, commandoutput );
        else
            dbstack;
            error( '%s: Copy failed.\n    Command: %s\n    Output: %s\n', mfilename(), copyCommand_safe, commandoutput );
        end
    end
end

function s = makeScpCommand( scpcommand, sourcefile, targetfile )
    s = sprintf( '%s ''%s'' ''%s''', ...
                 scpcommand, ...
                 sourcefile, ...
                 targetfile );
end

