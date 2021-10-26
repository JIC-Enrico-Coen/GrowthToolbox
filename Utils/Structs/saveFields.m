function [s,r] = saveFields( s, r )
%[s,r] = saveFields( s, r )
%   For every field f of r, swap the values of s.(f) and r.(f).
%   It is assumed that every field of r is a field of s.

    r1 = r;
    fn = fieldnames(r);
    r = setFromStructFields( r, s, fn{:} );
    s = setFromStruct( s, r1 );
end
