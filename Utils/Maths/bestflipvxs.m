function pts = bestflipvxs( pts )
%pts = bestflipvxs( pts )
% pts is an Nx2 matrix of N points in the plane.
% Reflect this set about a line chosen to minimise the total squared
% displacement of all the points.

    centroid = sum(pts,1)/size(pts,1);
    pts = pts - repmat( centroid, size(pts,1), 1 );
    X = sum(pts(:,1).^2);
    Y = sum(pts(:,2).^2);
    Z = sum( pts(:,1).*pts(:,2) );
    theta = atan2( 2*Z, X-Y )/2;
    v = [ cos(theta), sin(theta) ];
    repv = repmat( v, size(pts,1), 1 );
    dots = dot( pts, repv, 2 );
    pts = repv.*repmat( 2*dots, 1, 2 ) - pts + repmat( centroid, size(pts,1), 1 );
end
