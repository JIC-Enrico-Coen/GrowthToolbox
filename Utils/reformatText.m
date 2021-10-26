function s = reformatText( s )
%s = reformatText( s )
%   Delete all spaces after a newline.
%   Wherever s contains a single newline not followed by a space, replace
%   it by a space.  Leave all other newlines alone.  Delete all trailing
%   spaces.

    s = canonicalNewlines( s );
    s = regexprep( s, '([^\n])\n([^\n ])', '$1 $2' );
    s = regexprep( s, [ ' *' char(10) ], char(10) );
    s = regexprep( s, ' *$', '' );
end
