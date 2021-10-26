function v = execcmds( filename, syntaxdef, v, do )
%v = execcmds( filename, syntaxdef, v )
%   Apply commands from the given file, with meanings defined by syntaxdef,
%   to the structure v.

    if nargin < 4, do = 1; end
%    do = 0; % Safety while debugging.

    ts = opentokenstream( filename );
    if isempty(ts)
        % Error.
        fprintf( 1, 'execcmds: Cannot read from file %s.\n', filename );
        return;
    end
    v = [];
    [ts,v] = tscmds( ts, syntaxdef, v, do );
    [ts,t] = peektoken(ts);
    if ~isempty(t)
        fprintf( 1, 'execcmds: input terminated on line %d by token "%s".\n', ...
            ts.curline, t );
    end
    ts = closetokenstream( ts );
end

