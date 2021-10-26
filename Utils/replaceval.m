function a = replaceval( a, oldval, newval )
%a = replaceend( a, oldval, newval )
%   Replace every occurrence of OLDVAL in A by NEWVAL.

    a( a==oldval ) = newval;
end
