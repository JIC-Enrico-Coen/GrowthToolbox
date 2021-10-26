function s = loadAddToStruct( filename, s, mode )
%s = loadAddToStruct( filename, s )
%   Load a struct from the file, and add its fields to s.  Fields not
%   present in s will be added.  Fields already present in s will be
%   overwritten if MODE is 'override', and discarded otherwise.

    if nargin < 3
        mode = '';
    end
    s1 = load( filename );
    if strcmp(mode,'override')
        s = setFromStruct( s, s1 );
    else
        s = defaultFromStruct( s, s1 );
    end
end
