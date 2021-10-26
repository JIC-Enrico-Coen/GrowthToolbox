function [ok,commandoutput] = executeRemote( remotecmd, ignoreerrors )
%[ok,commandoutput] = executeRemote( remotecmd, ignoreerrors )
%   Execute a command on the remote machine.

    global DryRun

    if nargin < 2
        ignoreerrors = false;
    end
    
    fullremotecommand = make_ssh_command( remotecmd );
    
    if DryRun
        fprintf( 1, 'DRY RUN: %s\n', fullremotecommand );
        ok = true;
        commandoutput = '';
    else
        fprintf( 1, '%s: About to remotely execute command:\n    %s\n', mfilename(), fullremotecommand );

        [status, commandoutput] = system(fullremotecommand);

        if contains(commandoutput,'Access denied')
            fprintf( 1, '%s: output contains ''Access denied'', status = %d\n    %s\n', milename, status, commandoutput );
            status = 1;
        end

        ok = status==0;
        logClusterCommand( fullremotecommand, boolchar( ok, 'Success', commandoutput ) );
    end
    
    if ~ok && ~ignoreerrors
        dbstack;
        error( '%s: Remote execution failed:\nCommand: %s\nOutput: %s\n', mfilename(), fullremotecommand, commandoutput );
    end
end

function s = make_ssh_command( remotecmd )
    global RemoteUserName ClusterName
    getClusterDetails();
    
    s = sprintf('ssh %s@%s %s', RemoteUserName, ClusterName, remotecmd );
end

