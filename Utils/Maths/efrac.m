function [r,n,d] = efrac( cf, i )
%r = efrac( cf )
%   Evaluate a continued fraction.

    n = cf(length(cf));
    d = 1;
    for j=(length(cf)-1):-1:1
        d1 = n;
        n = d+cf(j)*n;
        d = d1;
    end
    r = n/d;
end

function r = xefrac( cf, i )
%r = efrac( cf )
%   Evaluate a continued fraction.

    r = cf(length(cf));
    for j=(length(cf)-1):-1:1
        r = cf(j)+1/r;
    end
end
