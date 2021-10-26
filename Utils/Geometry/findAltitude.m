function [v,a,b] = findAltitude( v1, v2, v3 )
%[v,a,b] = findaltitude( v1, v2, v3 )
%   v is the foot of the perpendicular from v1 to the line v2 v3.
%   v is equal to a*v2 + b*v3.

    dv = v3-v2;
    v32sq = dot(dv,dv);
    if v32sq==0
        v = zeros(size(v1));
    else
        a = dot(v3-v1,dv)/v32sq;
        b = 1-a;
        v = a*v2 + b*v3;
    end
end
