function ac = isAnticlockwisePoly2D( vxs, polys )
%ac = isAnticlockwisePoly2D( vxs, polys )
%   VXS is an N*2 array specifying N points in the plane.
%   POLYS is a cell array of vectors of indexes into VXS, each vector
%   specifying a polygon.  The polygons are assumed to be convex.
%   The result is a vector of booleans, one for each polygon, specifying
%   whether the polygon's vertexes are listed in anticlockwise order.

    ac = true( length(polys), 1 );
    for i=1:length(polys)
        poly = polys{i};
        v = vxs(poly,:);
        v = v(2:end,:) - repmat( v(1,:), size(v,1)-1, 1 );
        angles = atan2( v(:,2), v(:,1) )';
        ac(i) = cyclicAngles( angles );
    end
end
