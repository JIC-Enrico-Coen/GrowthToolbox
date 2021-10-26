function [near,far] = nearfarpoints( p, ps )
%[near,far] = nearfarpoints( p, ps )
%   Find the nearest and farthest points in the set ps from the point p.
%   Return their indexes.  p is a row vector of length D, and ps is an N*D
%   matrix.

    dsq = sum( (ps - repmat( p, size(ps,1), 1 )).^2, 2 );
    [x,near] = min( dsq );
    [x,far] = max( dsq );
end
