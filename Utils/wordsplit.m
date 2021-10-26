function toks = wordsplit( str, delimiters )
%toks = wordsplit( str, spacing, delimiters )
%   The string STR is split into tokens.  Any sequence of one or more
%   whitespace characters is deleted and replaced by a token
%   break.  DELIMITERS is a string or a cell array of strings: every
%   occurrence in STR of any of these strings is taken to be a token.
%   The result is a cell array of strings.

    if isempty(str)
        toks = {};
        return;
    end
    
    spacingpat = '\s+';
    [ si, ei ] = regexp( str, spacingpat, 'start', 'end' );
    si = [ (si-1), length(str) ];
    ei = [ 1 (ei+1) ];
    toks = {};
    for i=1:length(si)
        tok = str( ei(i):si(i) );
        subtoks = splitdelimiters( tok, delimiters );
        toks = [ toks, subtoks ];
    end
end

function toks = splitdelimiters( s, d )
    if isempty(d)
        toks = {s};
        return;
    end
    if ischar(d)
        d = { d };
    end
    delimpts = [0 length(s)];
    for i=1:length(d)
        % ds = regexprep( d{i}, '([\\\[\]\(\)\.])', '\\$1' );
        ds = d{i};
        [ si, ei ] = regexp( s, ds, 'start', 'end' );
        delimpts = unique( [si-1 ei delimpts] );
    end
    toks = {};
    delimpts
    for i=2:length(delimpts)
        toks{i-1} = s( (delimpts(i-1)+1):delimpts(i) );
    end
end
