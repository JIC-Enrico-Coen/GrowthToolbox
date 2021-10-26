function [p,pbary,v,e] = lineTriangleIntersection( line, tri, insideonly )
%[p,pbary,v,e] = lineTriangleIntersection( line, tri, insideonly )
%   Find the intersection of a line and a triangle in 3D.
%   The line is represented as a 2x3 matrix consisting of two 3D points,
%   defining the infinite line passing through them.  The triangle is a 3x3
%   matrix whose rows are the vertexes of the triangle.
%
%   The result is the intersection point, its barycentric coordinates
%   with respect to the triangle, and the vertex and edge that the point is
%   closest to.  The point is in the interior of the 
%   triangle if the barycentric coordinates are all positive, on the
%   interior of an edge if exactly one is zero, at a vertex if two are
%   zero, and outside the triangle if any are negative.
%
%   If the triangle or the line are degenerate, or the line lies in the
%   plane of the triangle, then p and pbary are both  returned as all
%   zeros.  Note that [0 0 0] is not a valid set of barycentric
%   coordinates.
%
%   If insideonly is true (the default is false), then if the point lies
%   outside it will be returned as zero, with barycentric coordinates of
%   zero.  Note that due to rounding errors it is possible that a point
%   exactly on the edge of the triangle will be detected as lying outside.

    NEWVERSION = true;
    if NEWVERSION
        if nargin < 3
            insideonly = false;
        end
        p1 = line(1,:);
        a = tri(1,:) - p1;
        b = tri(2,:) - p1;
        c = tri(3,:) - p1;
        p12 = line(2,:) - line(1,:);
        
        % The intersection point is p = beta*p12, for that beta which makes
        % the triple product | p-a p-b p-c | zero.  Multiplying out the
        % determinant, the cubic and quadratic terms in beta are zero, and
        % the condition reduces to beta = |a b c|/|p12 a-b a-c|.  The
        % numerator is equal to |a a-b a-c|, which allows the computation
        % of (a-b)x(a-c) to be shared.

        abac = cross(a-b,a-c);
        denominator = dot(p12,abac);
        if denominator==0
            p = [0 0 0];
            pbary = [0 0 0];
            return;
        end
        beta = dot(a,abac)/denominator;
        p0 = beta*p12;
        p = p1 + p0;
    
        % Check: checkinplane is zero if p does indeed lie in the plane of
        % the triangle.
%       checkinplane = dot( tri(1,:)-p, cross( tri(2,:)-p, tri(3,:)-p ) )

        % The barycentric coordinates of p are proportional to the volumes
        % enclosed in p12bc, p12ca, and p12ab.
        pbary = p12 * [ cross(b,c); cross(c,a); cross(a,b) ]';
        pbary = pbary/sum(pbary);
        % Check: checkpbary is zero if the barycentric coordinates
        % are correct.
%       checkpbary = pbary*tri - p
        if insideonly && any(pbary < 0)
            p = [0 0 0];
            pbary = [0 0 0];
            v = 0;
            e = 0;
        elseif nargout >= 3
            apb = abs( pbary );
            [ignore,v] = max(apb);
            [ignore,e] = min(apb);
        end
    else
        if ~exist('normal','var')
            v12 = tri(2,:) - tri(1,:);
            v13 = tri(3,:) - tri(1,:);
            normal = cross( v12, v13 );
        end
        p = lineplaneIntersection( line(1,:), line(2,:), normal, tri(1,:) );
    end
end
