function [v,d] = cloudAxes( p )
%a = cloudAxes( p )
%   Determine the principal axes of the cloud of points p.  p is an N*D
%   matrix, where there are N points in D dimensional space.

    covmatrix = cov(p);
    [v,d] = eig(covmatrix);
end
