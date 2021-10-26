function ok = beginsWithString( s, prefix )
%ok = beginsWithString( s, prefix )
%   For strings S and PREFIX, determine whether S begins with PREFIX.
%
%   See also: removeStringPrefix, removeStringSuffix.

    if iscell(s)
        ok = false(1,length(s));
        for i=1:length(s)
            ok(i) = (length(prefix) <= length(s{i})) && all( prefix==s{i}(1:length(prefix)) );
        end
    else
        ok = (length(prefix) <= length(s)) && all( prefix==s(1:length(prefix)) );
    end
end
