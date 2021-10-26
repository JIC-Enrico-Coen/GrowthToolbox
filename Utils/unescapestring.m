function s = unescapestring( s )
    [toks,seps] = splitString( '(\\.|%%|'''')', s );
    if isempty(seps)
        return;
    end
    c = cell2mat( seps );
    c = unescapechars( c(:,2) );
    for i=1:length(c)
        toks{i} = [ toks{i} c(i) ];
    end
    s = cell2mat(toks');
end

