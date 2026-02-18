function [ok,commandoutput] = executeRemote( remotecmd, ignoreerrors )
%[ok,commandoutput] = executeRemote( remotecmd, ignoreerrors )
%   Execute a command on the remote machine.

    global DryRun SshBackground NumRemoteCommands
    
%     if isempty(SshBackground) || ~SshBackground
%         [ok,result] = system( 'ssh -fN hali.uea.ac.uk' );
%         SshBackground = true;
%     end
    

    if nargin < 2
        ignoreerrors = false;
    end
    
    externalcommand = make_ssh_command( remotecmd );
    
    accessDenied = false;
    
    if DryRun
        fprintf( 1, 'DRY RUN: %s\n', externalcommand );
        ok = true;
        commandoutput = '';
    else
        if isempty(NumRemoteCommands)
            NumRemoteCommands = 1;
        else
            NumRemoteCommands = NumRemoteCommands + 1;
        end
        fprintf( 1, '%s: About to remotely execute command %d:\n    %s\n', mfilename(), NumRemoteCommands, externalcommand );

        [status, commandoutput] = system(externalcommand); ok = status==0;
        accessDenied = contains(commandoutput,'Access denied');

        if accessDenied
            fprintf( 1, '%s: output contains ''Access denied'', status = %d\n    %s\n', milename, status, commandoutput );
            status = 1;
        end

        logClusterCommand( externalcommand, boolchar( ok, 'Success', commandoutput ) );
        
        if ~ok && ~ignoreerrors && ~accessDenied
            ok = attemptExternalCommand( externalcommand, commandoutput );
        end
    end
    
    if ~ok && ~ignoreerrors && ~accessDenied
        xxxx = 1;
        if ~ok && ~ignoreerrors && ~accessDenied
            dbstack;
            error( '%s: Remote execution failed:\nCommand %d: %s\nOutput: %s\n',...
                mfilename(), NumRemoteCommands, externalcommand, commandoutput );
        end
    end
end

function s = make_ssh_command( remotecmd )
    global RemoteUserName ClusterName
    getClusterDetails();
    
    s = sprintf('ssh %s@%s %s', RemoteUserName, ClusterName, remotecmd );
end

