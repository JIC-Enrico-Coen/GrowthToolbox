function [theta,centroid] = bestFitLine2D( pts )
%theta = bestFitLine2D( pts )
%   Find the direction of the line through the centroid of the given points
%   that minimises the sum of the squares of the distances of the points
%   from the line.
%   pts must be an N*2 array.  theta will be an angle between -PI/2 and
%   +PI/2.  Both limits are possible.

    centroid = sum(pts,1)/size(pts,1);
    pts = pts - repmat( centroid, size(pts,1), 1 );
    X = sum(pts(:,1).^2);
    Y = sum(pts(:,2).^2);
    Z = sum( pts(:,1).*pts(:,2) );
    theta = atan2( 2*Z, X-Y )/2;
end
