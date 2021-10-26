function s = canonicalNewlines( s )
%s = canonicalNewlines( s )
%   Force Unix newline convention: replace crlf and cr by lf.

    s = regexprep( s, [ char(13) char(10) ], char(10) );
    s = regexprep( s, char(13), char(10) );
end
