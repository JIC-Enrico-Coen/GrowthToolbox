function [v1,v2,v3] = findvertexes( p1, p2, f )
%[v1,v2,v3] = findvertexes( p1, p2, f )  Find where nodes p1 and p2 occur in face f.
%    We require that p1==f(v1), p2==f(v2), and f(v3) is the third vertex.
%    Used in the edge-splitting routine SPLITEDGE.

v1 = 0;
v2 = 0;
v3 = 0;
for i=1:3
    if p1==f(i),
        v1 = i;
    elseif p2==f(i),
        v2 = i;
    else
        v3 = i;
    end
end
if (v1==0) || (v2==0) || (v1==v2),
    dbstop in findvertexes.m at 18
    error('%s:  Looking for (%d,%d) cell has (%d,%d,%d).', ...
        mfilename(), p1, p2, f(1), f(2), f(3) );
end
end
