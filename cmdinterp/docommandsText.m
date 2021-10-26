function m = docommandsText( m, cmdtext, varargin )
%m = docommandsText( m, cmdtext, varargin )
%   Execute Matlab commands from the cell array of strings.  The optional
%   arguments can request the leaf to be plotted after each leaf command, and
%   for execution to be paused after each leaf command.  Each command is echoed
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

    doplot = 0;
    dopause = 0;
    h = [];
    i = 1;
    while i <= length(varargin)
        switch varargin{i}
            case 'plot'
                doplot = 1;
            case 'pause'
                dopause = 1;
                doplot = 1;
            case 'handles'
                if i < length(varargin)
                    i = i+1;
                    h = varargin{i};
                end
            otherwise
                fprintf( 1, 'Unknown option "%s" to docommandstext() ignored.\n', varargin{i} );
        end
        i = i+1;
    end
    if ischar(cmdtext), cmdtext = { cmdtext }; end
    for linenum=1:length(cmdtext)
        s = cmdtext{linenum};
        fprintf( 1, '%s  %% %d\n', s, linenum );
        leafcommand = regexp( s, '^\s*m\s*=\s*leaf_(\w+)\s*(', 'tokens' );
%         try
            eval( s );
%         catch e
%             beep;
%             fprintf( 1, 'Warning: %s\n', regexprep( e.message, '^Error: ', '' ) );
%             fprintf( 1, 'Syntax error on line %d:\n    %s\n', linenum, s );
%             return;
%         end
        if doplot ...
           && ~isempty(m) ...
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
                fprintf( 1, 'Execution interrupted.\n' );
                return;
            end
        end
    end
end