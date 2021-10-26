function [q,r] = gramschmidt( a )
%[q,r] = gramschmidt( a )
%   Gram-Schmidt orthogonalisation.
%   From http://web.mit.edu/18.06/www/Essays/gramschmidtmat.pdf
%   a is an M*N matrix, consisting of N M-dimensional column vectors.
%   q will be their orthogonalisation.  All vectors of q will have unit
%   length and they will be orthogonal to each other.
%
%   r will be a matrix with the property that q*r = a.
%
%   If any column of a is zero, the corresponding column of q and all later
%   columns will be NaN.  All later columns of r will be NaN.


    sa = size(a);
    q = zeros(sa);
    r = zeros(sa(2),sa(2));
    for j=1:sa(2)
        v = a(:,j);
        for i=1:j-1
            r(i,j) = q(:,i)' * a(:,j);
            v = v - r(i,j)*q(:,i);
        end
        r(j,j) = norm(v);
        q(:,j) = v/r(j,j);
    end
end
