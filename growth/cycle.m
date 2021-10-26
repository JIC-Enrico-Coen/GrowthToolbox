function y = cycle( x,n )
%CYCLE( X, N ) return a cyclic permutation of x.
%  N is the amount to rotate x by: cycle(x,1) will return
%  the list resulting from moving the first element of x
%  to the end.  N can be any integer.
    p = size(x,2);
    n = mod(n,p);
    if n==0, n = p; end
    y = [x((n+1):size(x,2)) x(1:n)];
end


