function [s,ok] = replaceStringPrefix( s, oldprefix, newprefix )
%s = removeStringPrefix( s, prefix )
%   For strings S and PREFIX, if S begins with PREFIX, remove PREFIX and
%   set S to the remainder and OK to true.  Otherwise, leave S unchanged
%   and set OK to false.
%
%   See also: beginsWithString, removeStringSuffix.

    if length(oldprefix) > length(s)
        ok = false;
    elseif all( oldprefix==s(1:length(oldprefix)) )
        s = [newprefix s((length(oldprefix)+1):end)];
        ok = true;
    else
        ok = false;
    end
end
