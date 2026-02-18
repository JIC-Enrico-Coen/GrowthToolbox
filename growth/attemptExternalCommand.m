function [ok,commandoutput] = attemptExternalCommand( externalcommand, commandoutput, maxattempts )
%ok = attemptExternalCommand( externalcommand, commandoutput )
%	Repeatedly try an external command (using system()) up to 10 times,
%	with pauses between. After that, offer the user the choice to try again
%	or give up.
%
%   COMMANDOUTPUT, if supplied and nonempty, is the result of a previous
%   attempt to execute the command.
%
%   The OK result says whether the execution was ultimately successful.
%
%   The COMMANDOUTPUT result is the output from the final attempt (whether
%   successful or not).
%
%   The reason for having this function at all is that sometimes, sending a
%   command for execution on a remote machine, using ssh or scp, randomly
%   gives me a broken connection, but retrying after seconds to minutes can
%   succeed. This function automates the process of making a number of
%   retries automatically, then if the failure persists, letting the user
%   decide whether to continue retrying.
%
%   See also: system

    global NumRemoteCommands
    ok = false;
    numattempts = 0;
    if nargin < 3
        maxattempts = 5;
    end
    statuses = [];
    commandoutputs = {};
    shouldRetry = true;
    status = -1;
    
    while ~ok && ((numattempts < maxattempts) || shouldRetry)
        if (numattempts==0) || ((nargin >= 2) && ~isempty( commandoutput ))
            fprintf( 1, '%s: Command failed.\n    Command: %s\n    Output: %s\nRetrying, attempt %d of %d...', ...
                mfilename(), externalcommand, commandoutput, numattempts, maxattempts );
            statuses(numattempts+1) = status; %#ok<AGROW>
            commandoutputs{numattempts+1} = commandoutput; %#ok<AGROW>
        end
        if numattempts < maxattempts
            pause( 2 );
        end
        [status, commandoutput] = system(externalcommand);
        ok = status==0;
        if ok
            NumRemoteCommands = 1;
            timedFprintf( 'Command count reset to %d.\n', NumRemoteCommands );
        end
        logClusterCommand( externalcommand, boolchar( ok, 'Success', commandoutput ) );
        numattempts = numattempts+1;
        if ~ok && (numattempts >= maxattempts)
            retryAnswer = input( sprintf( 'Command failed %d times. Retry? (y/n) ', numattempts ), "s" );
            shouldRetry = isempty(retryAnswer) || (lower( retryAnswer(1) ) ~= 'n');
        end
    end
end
