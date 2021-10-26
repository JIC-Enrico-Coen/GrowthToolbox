function p = intersectPolygons( p1, p2 )
%p = intersectPolygons( p1, p2 )
%   Compute the intersection of two convex polygons.
%   The polygons are represented as N*2 arrays containing their vertexes in
%   anticlockwise order.
%   The vertexes of the intersection are:
%   (1) Every vertex of one that lies inside the other, and
%   (2) Every intersection of any edge of one with any edge of the other.
%   The only edges that need be tested are those from a point inside to a
%   point outside, and between two points outside.
%   WARNING: This is wrong.  Consider two rectangles overlapping to form a
%   Swiss cross.  Neither has any vertexes inside the other.
    
    numpts1 = size(p1,1);
    numpts2 = size(p2,2);
    p1in2 = zeros( 1, numpts1 );
    p2in1 = zeros( 1, numpts2 );
    for i=1:numpts1
        p1in2(i) = pointInPoly( p1(i,:), p2 );
    end
    for i=1:numpts2
        p2in1(i) = pointInPoly( p2(i,:), p1 );
    end
end
