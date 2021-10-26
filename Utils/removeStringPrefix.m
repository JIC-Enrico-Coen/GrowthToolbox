function [s,ok] = removeStringPrefix( s, prefix )
%s = removeStringPrefix( s, prefix )
%   For strings S and PREFIX, if S begins with PREFIX, remove PREFIX and
%   set S to the remainder and OK to true.  Otherwise, leave S unchanged
%   and set OK to false.
%
%   See also: beginsWithString, removeStringSuffix.

    if length(prefix) > length(s)
        ok = false;
    elseif all( prefix==s(1:length(prefix)) )
        s = s((length(prefix)+1):end);
        ok = true;
    else
        ok = false;
    end
end
