function [s,ok] = removeStringPrefix( s, prefix, ignorecase )
%s = removeStringPrefix( s, prefix, ignorecase )
%   For strings S and PREFIX, if S begins with PREFIX, remove PREFIX and
%   set S to the remainder and OK to true.  Otherwise, leave S unchanged
%   and set OK to false.
%
%   IGNORECASE defaults to false. If true, the comparison of PREFIX with
%   the start of S ignores case.
%
%   See also: beginsWithString, removeStringSuffix.

    if nargin < 3
        ignorecase = false;
    end
    
    if length(prefix) > length(s)
        ok = false;
    else
        if ignorecase
            match = all( lower(prefix)==lower(s(1:length(prefix))) );
        else
            match = all( prefix==s(1:length(prefix)) );
        end
        if match
            s = s((length(prefix)+1):end);
            ok = true;
        else
            ok = false;
        end
    end
end
