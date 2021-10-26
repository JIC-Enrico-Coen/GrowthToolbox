function f = makeFunctionName( s )
%ifname = makeIFname( modelname )
%   Turn an arbitrary string into something that can be a valid Matlab
%   function name or struct field name.  If this is not possible, return
%   the empty string.
%
%   All runs of non-alphanumerics are replaced
%   by underscore, and the resulting string must begin with a letter.

    f = regexprep( s, '[^A-Za-z0-9_]+', '_' );
    beginsWithLetter = regexp( f, '^[A-Za-z]' );
    if isempty(beginsWithLetter)
        f = '';
    end
end
