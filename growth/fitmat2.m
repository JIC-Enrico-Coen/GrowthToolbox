function [m,t] = fitmat2( p0, p1 )
%m = fitmat( p0, p1 )
%   P0 and P1 are N*2 or N*3 arrays of 2D or 3D vectors.
%   [M,T] are the linear transformation and translation that best
%   approximate the transformation of P0 to P1.
%   T is P1mean-P0mean, and M is chosen to minimise the squared error of
%   (P1-P1mean) - (P0-P0mean)*M.

    x = [p0,ones(size(p0,1),1)] \ (p1-p0);
    m = x(1:(size(x,1)-1),:) + eye(size(x,2));
    t = sum(p1-p0,1)/size(p0,1); % x(size(x,1),:);
end
