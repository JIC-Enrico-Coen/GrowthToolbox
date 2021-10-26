function [s,ok] = removeStringSuffix( s, suffix )
%s = removeStringSuffix( s, suffix )
%   For strings S and SUFFIX, if S begins with SUFFIX, remove SUFFIX and
%   set S to the remainder and OK to true.  Otherwise, leave S unchanged
%   and set OK to false.
%
%   See also: beginsWithString, removeStringPrefix.

    if length(suffix) > length(s)
        ok = false;
    else
        remainder = length(s)-length(suffix);
        if all( suffix==s((remainder+1):end) )
            s = s(1:remainder);
            ok = true;
        else
            ok = false;
        end
    end
end
