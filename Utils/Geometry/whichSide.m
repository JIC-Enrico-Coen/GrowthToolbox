function [z,zz] = whichSide( n, p, v )
%[z,zz] = whichSide( n, p, v )
%   z is 1, 0, or -1, depending on which side v is of
%   the hyperplane perpendicular to n through p.
%   n and p must be row vectors, and v a matrix of row vectors.
%   z will be a column vector of booleans.
%   zz is the continuous measure of which z is the sign.

    zz = ((v - (ones(size(v,1),1) * p)) * n');
    z = sign(zz);
end
