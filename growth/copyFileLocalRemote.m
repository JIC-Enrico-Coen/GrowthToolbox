function ok = copyFileLocalRemote( localfile, remotefile, direction, move, ignoreerrors )
%ok = copyFileLocalRemote( localfile, remotefile, direction, move, ignoreerrors )
%   Copy a file between the local machine and the remote machine, using the
%   scp command. The remote filename must be relative to the remote user's
%   home directory. The local filename may be relative or absolute in the
%   normal way.
%
%   If DIRECTION is '>' the file is copied from the local
%   machine to the remote machine. If it is '<', it is copied from the
%   remote machine to the local machine.
%
%   If MOVE is true (it defaults to false), then if the copy
%   is successful, the source file will then be deleted. MOVE is only
%   implemented for local-to-remote copies of a single file. For any other
%   sort of copy it will be ignored.
%
%   If IGNOREERRORS is true (it defaults to false), then if the operation
%   fails, a message will be output and execution will continue. If false,
%   an error will be thrown if the operation fails.

    global DryRun NumRemoteCommands

    global RemoteUserName ClusterName
    getClusterDetails();
    
    if (nargin < 4) || isempty( move )
        move = false;
    end
    if (nargin < 5) || isempty( ignoreerrors )
        ignoreerrors = false;
    end
    
%     pscpcommand = sprintf( '%spscp%s', pathstring );
%     REMOTECOPYCOMMAND = 'scp';
    REMOTECOPYCOMMAND = 'rsync';
    scpcommand = [ REMOTECOPYCOMMAND ' -p' ]; % The -p flag preserves file flags and dates. In particular, executable files sdfasfasdf
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

    externalcommand = makeScpCommand( scpcommand, sourcefile, targetfile );
    
    if DryRun
        fprintf( 1, 'DRY RUN: %s: About to %s %s to %s\n', mfilename, boolchar( move, 'move', 'copy' ), sourcefile, targetfile );
        ok = true;
    else
        if isempty(NumRemoteCommands)
            NumRemoteCommands = 1;
        else
            NumRemoteCommands = NumRemoteCommands + 1;
        end
        fprintf( 1, '%s: Command %d, about to %s %s to %s\n', mfilename, NumRemoteCommands, boolchar( move, 'move', 'copy' ), sourcefile, targetfile );

        [status,commandoutput] = system( externalcommand ); ok = status==0;
        logClusterCommand( externalcommand, boolchar( ok, 'Success', commandoutput ) );
        if ~ok && ~ignoreerrors
            ok = attemptExternalCommand( externalcommand, commandoutput );
        end

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
            fprintf( 1, '%s: Copy failed.\n    Command %d: %s\n    Output: %s\n',...
                mfilename(), NumRemoteCommands, externalcommand, commandoutput );
        else
            xxxx = 1;
            if ~ok
                dbstack;
                error( '%s: Copy failed.\n    Command %d: %s\n    Output: %s\n',...
                    mfilename(), NumRemoteCommands, externalcommand, commandoutput );
            end
        end
    end
end

function s = makeScpCommand( scpcommand, sourcefile, targetfile )
    s = sprintf( '%s %s ''%s''', ...
                 scpcommand, ...
                 sourcefile, ...
                 targetfile );
end

