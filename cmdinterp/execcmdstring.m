function v = execcmdstring( s, syntaxdef, v, do )
%v = execcmdstring( s, syntaxdef, v, do )
%   Apply the commands contained in the string s, with meanings defined by
%   syntaxdef,
%   to the structure v.

    if nargin < 4, do = 1; end
%    do = 0; % Safety while debugging.

    ts = stringtokenstream( s );
    if isempty(ts)
        % Error.
        fprintf( 1, 'execcmds: Cannot read from file %s.\n', filename );
        return;
    end
    [ts,v] = tscmds( ts, syntaxdef, v, do );
    [ts,t] = peektoken(ts);
    if ~isempty(t)
        fprintf( 1, 'execcmds: input terminated on line %d by token "%s".\n', ...
            ts.curline, t );
    end
end

