function isfull = isFullPathname( f )
%isfull = isFullPathname( f )
%   Determine whether F is a full path name. It is deemed to be so if it
%   begins with a '/', a '\', or a letter followed by a ':'.
%
%   This is a purely syntactic check. No check is made to see if F is the
%   name of any existing file or directory. In addition, occurrence of any
%   of the three prefixes is taken to indicate that it is a full path name,
%   regardless of whether they are valid prefixes for any currently mounted
%   file system. The remainder of F is also not checked to see if it
%   contains characters that may be invalid for file paths.
%
%   F can have type char or string. If it is a cell array (possibly
%   nested), a corresponding cell array of results is returned. If it is
%   anything else the result is false.

    if isstring(f)
        f = char(f);
    end
    
    if iscell(f)
        isfull = cell(size(f));
        for i=1:numel(f)
            isfull{i} = isFullPathname( f{i} );
        end
    elseif ~ischar(f)
        isfull = false;
    elseif isempty(f)
        isfull = false;
    elseif f(1)=='/'
        isfull = true;
    elseif f(1)=='\'
        isfull = true;
    elseif regexp( f, '^[A-Za-z]:' )
        isfull = true;
    else
        isfull = false;
    end
end
