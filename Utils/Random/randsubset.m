function y = randsubset( x, p )
%y = randsubset( x, p )
%   X is a vector of length N.  Y is set to a vector of ceil(p*N) randomly
%   chosen elements of X.  The elements of Y have the same ordering as in
%   X.

    if p <= 0
        y = [];
    elseif p >= 1
        y = x;
    else
        nx = length(x);
        ny = ceil( p*nx );
        bitmap = [ true(1,ny), false(1,nx-ny) ];
        y = x( bitmap( randperm(nx) ) );
    end
end
