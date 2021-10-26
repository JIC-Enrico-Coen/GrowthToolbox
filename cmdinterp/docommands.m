function m = docommands( m, filename, varargin )
%m = docommands( m, filename, varargin )
%   Execute Matlab commands from the file.  The optional arguments can
%   request the leaf to be plotted after each leaf command, and for
%   execution to be paused after each leaf command.  Each command is echoed
%   to the terminal window before it is executed.
%
%   Leaf commands are defined to be Matlab statements of the form
%       m = leaf_xxxxxx( ... );
%   where leaf_xxxxxx is a command for creating or modifying a leaf.
%   Note that the left hand side of the assignment must be the variable m.
%   The result of docommands is the result of the final leaf command.
%
%   Every command in the Matlab file must be on a single line.  This
%   includes compound commands such as for-loops: the entire for...end must
%   be on a single line.
%
%   Options:
%       'plot': draw the leaf after every command (except for leaf_plot
%           commands, which draw the leaf themselves).
%       'pause': pause Matlab after each command.  'pause' implies 'plot'.
%       'nostop': Don't try to execute the file line by line, just eval the
%                 entire contents at once.

    doplot = 0;
    dopause = 0;
    nostop = 0;
    h = [];
    for i=1:length(varargin)
        switch varargin{i}
            case 'plot'
                doplot = 1;
            case 'pause'
                dopause = 1;
                doplot = 1;
            case 'nostop'
                nostop = 1;
            case 'handles'
                if i < length(varargin)
                    h = varargin{i+1};
                end
            otherwise
                fprintf( 1, 'Unknown option "%s" to docommands() ignored.\n', varargin{i} );
        end
        i = i+1;
    end
    fprintf( 1, 'docommands: doplot %d dopause %d nostop %d\n', ...
        doplot, dopause, nostop );
    fid = fopen( filename );
    if fid == -1
        fprintf( 1, 'Cannot read from file %s.\n', filename );
        return;
    end
    if nostop
        fprintf( 1, 'Executing file %s:\n ', filename );
        s = readWholeFile( fid );
%         try
            eval( s );
%         catch e
%             beep;
%             fprintf( 1, 'Warning: %s\n', regexprep( e.message, '^Error: ', '' ) );
%             fprintf( 1, 'Error while executing file %s:\n    %s\n', filename, s );
%             return;
%         end
        if doplot
            m = leaf_plot( m );
        end
    else
        linenum = 0;
        while true
            s = fgetl( fid );
            if s == -1
                fprintf( 1, '%% Finished file %s.\n', filename );
                if fid ~= 1
                    fclose(fid);
                end
                return;
            end
            linenum = linenum+1;
            fprintf( 1, '%s  %% %d %s\n', s, linenum, filename );
            leafcommand = regexp( s, '^\s*m\s*=\s*leaf_(\w+)\s*(', 'tokens' );
%             try
                eval( s );
%             catch e
%                 beep;
%                 fprintf( 1, 'Warning: %s\n', regexprep( e.message, '^Error: ', '' ) );
%                 fprintf( 1, 'Syntax error on line %d of %s:\n    %s\n', linenum, filename, s );
%                 return;
%             end
            if doplot ...
               && ~isempty(leafcommand) ...
               && ~strcmp( leafcommand{1}, 'plot' ) ...
               && isempty( regexp( s, 'leaf_plot', 'once' ) )
                m = leaf_plot( m );
            end
            if dopause && ~isempty(leafcommand), pause; end
            if ~isempty(h)
                c = get( h.commandFlag, 'UserData' );
                set( h.commandFlag, 'UserData', struct([]) );
                if ~isempty(c)
                    fprintf( 1, 'Execution of %s interrupted.\n', filename );
                    return;
                end
            end
        end
    end
end

