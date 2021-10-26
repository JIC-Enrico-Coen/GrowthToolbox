function s = deescape( s )
%s = deescape( s )
%   Replace backslash escapes in s by the characters they stand for.

    escchars = [ 's', 'n', 'b' ];
    realchars = [ char(32), char(10), char(8) ];
    for i=1:length(escchars)
        c = escchars(i);
        d = realchars(i);
        s = regexprep( s, ['\\',c], d );
    end
    s = regexprep( s, '\\(.)', '$1' );
end
