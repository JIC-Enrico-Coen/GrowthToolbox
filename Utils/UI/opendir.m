function [ok,msg] = opendir( dirname )
%[ok,msg] = opendir( dirname )
%   Open the named directory on the desktop, by default the current working
%   directory.  This works on Mac OS X and Windows systems.  It might work
%   on Linux or other Unix systems, but this has not been tested.
%
%   If dirname is a relative path name, it will be interpreted relative to
%   the current working directory.
%
%   If dirname is the name of a file, its containing directory will be opened.
%
%   If dirname does not exist, no action is taken.
%
%   status will be 0 for success and nonzero for failure.  If nonzero, then
%   msg will be an error message.  If the msg parameter is not asked
%   for, the message will be written to the Matlab console.
%
%   Note that the calls to 'system' always return 0, regardless of status
%   or failure.  So if the actual call to the operating system to open the
%   directory fails, there is no way for this procedure to detect that.
%
%   Note also that there is an inherent security hazard in embedding the
%   arbitrary string dirname into a shell command. This procedure attempts
%   to sanitize the string, without excluding valid directory names, but it
%   is difficult to guarantee this. When composing the command, the
%   directory name is enclosed in single quotes, and any single quotes in
%   the directory name are replaced by the 4-character string ''\'.
%   This assumes that the operating system command syntax never performs
%   any sort of interpretation within a single-quoted string.

    if nargin < 1
        dirname = pwd;
    end
    if ispc()
        % This is a Windows machine.
        command = 'explorer';
    elseif ismac()
        % This is a Mac.
        command = 'open';
    elseif isunix()
        % This is some sort of Unix other than Mac OS X.  "xdg-open" is the
        % command to open a directory on the desktop in some Linuxes, so we
        % try that.  "nautilus" applies to Gnome only.  Failing anything
        % else, we guess "open".
        commands = { 'xdg-open', 'nautilus', 'open' };
        for i=1:length(commands)
            status = system( [ 'which ', commands{i} ] );
            if status == 0, break; end
        end
        if status ~= 0
            % We couldn't find a command.  Give up.
            queryDialog( 1, 'I''m sorry, I can''t do that', ...
                'Unable to open desktop windows on this type of machine: %s.', ...
                computer() );
            return;
        end
        if status==0
            dirname = regexprep( dirname, '\\*', '/' );
        end
    else
        % We don't know what it is.  Guess.
        command = 'open';
    end
    if ispc()
        quotechar = '"';
    else
        quotechar = '''';
    end
    if ~ispc()
        % On non-windows machines, replace backslashes by forward slashes
        % in the directory name.
        dirname = regexprep( dirname, '\\*', '/' );
    end
    if ismac()
        % On a Mac, if the directory name begins with a slash, make sure it
        % begins with at least two.  This is a workaround for a Matlab bug
        % in the exist() function: exist() applied to a filename beginning
        % with a single slash will report that the file exists if it exists
        % in either in the current directory or at the root, rather than
        % only at the root.  Adding a second slash makes the path refer to
        % the same file, but exist() recognises it as referring only to the
        % root.
        dirname = regexprep( dirname, '^/', '//' );
    end
    
%     % Remove all single quotes and semicolons from dirname. This is a
%     % security measure that may exclude some valid directory names.
%     dirname = regexprep( dirname, '['';]*', '' );
    
    havedir = exist( dirname, 'dir' );
    havefile = (~havedir) && exist( dirname, 'file' );
    
    if havefile
        dirname = fullpath( dirname );
        dirname = fileparts( dirname );
        havedir = exist( dirname, 'dir' );
    end
    
    if havedir
        % Replace all single quotes by the 4-character string '\''.
        dirnameforcmd = regexprep( dirname, '''', '''\\''''' );
    
        fullcmd = [command, ' ', quotechar, dirnameforcmd, quotechar, ' &'];
        fprintf( 1, 'Executing system command:\n%s\n', fullcmd );
        [status,msg] = system( fullcmd );
    else
        status = 1;
        msg = 'not found';
    end
    
    ok1 = status==0;
    if (~ok1) && (nargout >= 1)
        fprintf( 1, '%s: failed with error %d: %s\nwhen opening %s\n', ...
            mfilename(), status, msg, dirname );
    end
    
    if nargout >= 1
        ok = ok1;
    end
end
