function tokenstream = stringtokenstream( s )
%Create a token input stream from a string or a cell array of strings.

    tokenstream = emptytokenstream();
    tokenstream.name = 'STRINGSTREAM';

    if iscell(s)
        for i=1:length(s)
            toks = tokeniseString( s{i} );
            tokenstream.tokens = { tokenstream.tokens{:} toks{:} };
        end
    else
        tokenstream.tokens = tokeniseString( s );
    end
end
