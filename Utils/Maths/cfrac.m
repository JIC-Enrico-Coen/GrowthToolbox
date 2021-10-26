function a = cfrac( r, n, tol )
%a = cfrac( r, n )
%   Calculate the continued fraction representation of r to n places.

    if nargin < 3
        tol = 1.0e-10;
    end
    a = zeros(1,n);
    for i=1:n
        j = floor(r);
        a(i) = j;
        r = r-j;
        if abs(r) < tol
            a = a(1:i);
            return;
        end
        r = 1/r;
    end
end
