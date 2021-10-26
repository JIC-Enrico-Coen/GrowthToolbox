function [inside,bc] = pointInPoly( pts, poly )
%inside = pointInPoly( pts, poly )
%   Determine whether the 2D points are inside the 2D polygon, by computing
%   the winding number of the polygon about the point.
%   The polygon is represented as an N*2 array containing its vertexes in
%   order (clockwise or anticlockwise).
%   The result is a bitmap specifying for each point whether it is inside
%   or outside.
%   The result is always correct for non-self-intersecting polygons.
%   If the polygon overlaps itself, points in some of the regions that it
%   divides the plane into may be classified as outside.

    boundsLo = min(poly,[],1);
    boundsHi = max(poly,[],1);
    inside = (pts(:,1)>=boundsLo(1)) & (pts(:,1)<=boundsHi(1)) ...
             & (pts(:,2)>=boundsLo(2)) & (pts(:,2)<=boundsHi(2));
    wantbc = nargout >= 2;
    if wantbc
        bc = zeros( size(pts,1), size(poly,1) );
    end
    
    for i=find(inside')
        pt = pts(i,:);
        relpoly = [ poly(:,1) - pt(1), poly(:,2) - pt(2) ];
        inside(i) = windingNumber( grad2( relpoly ) ) ~= 0;
        if wantbc && inside(i)
            bc(i,1:3) = baryCoordsN( poly([1 2 3],:), pt );
        end
    end
end

