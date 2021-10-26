function s = makeValidName( s, lettercase )
% Convert any string into a valid Matlab field name.
%
% If lettercase is 1, s will be converted to upper case, if -1, s will be
% converted to lower case, and otherwise (including if lettercase is
% omitted) there will be no case conversion.
%
% The other transformations are:
% Replace all characters having numeric value above 127 by underscores.
% Replace all non-word characters by underscores.
% Replace all strings of underscores by single underscores.
% If the result begins with '_', prefix 'X'.
% If the result does not begin with a letter, prefix 'X_'.
% The empty string is converted to 'X_'.

    if nargin >= 2
        switch lettercase
            case 1
                s = upper( s );
            case -1
                s = lower( s );
        end
    end

    s(s>127) = '_';
    s = regexprep( s, '\W', '_' );
    s = regexprep( s, '_+', '_' );
    if isempty(s)
        s = 'X_';
    elseif s(1) == '_'
        s = ['X' s];
    elseif (s(1) < 'A') || ((s(1) > 'Z') && (s(1) < 'a')) || (s(1) > 'z')
        s = ['X_' s];
    end
end
