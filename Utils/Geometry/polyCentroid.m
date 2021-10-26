function [ca,area,cv] = polyCentroid( v )
%[ca,area,cv] = polyCentroid( v )
%   Compute the areal centroid, area, and vertex centroid of the polygon
%   whose vertexes are the rows of V.  The polygon must be 2 or 3
%   dimensional, and CA and CV will have the same number of dimensions.
%
%   The areal centroid is the centroid of the whole area of the polygon,
%   while the vertex centroid is the average of all the vertexes.  If the
%   area is zero, the vertex centroid is returned as the areal centroid.
%
%   AREA and CV are computed in the course of computing CA, so these
%   additional results are available free.
%
%   If the polygon is non-planar, then the areal centroid and area are
%   calculated for the triangulation whose triangles are those formed by
%   the vertex centroid and each consecutive pair of vertexes.
%
%   For polygons that are two dimensional or are exactly parallel to the XY
%   plane, the sense of the component triangles will be accounted for, i.e.
%   a bow-tie quadrilateral will have the two wings of the tie given areas
%   of opposite sign.  This is not done for possibly non-planar polygons in
%   general orientation in 3D space.  For these, area is always
%   non-negative, and highly non-convex polygons will be given areas that
%   may not make immediate sense.
%
%   When the polygon is in the XY plane, 
%
%   Examples:
%     [cc,area,cv] = polyCentroid( [0 0;1 0;1 1;0 1] )
%     Results:
%         cc = [0.5000    0.5000]
%         area = 1
%         cv = [0.5000    0.5000]
%     [cc,area,cv] = polyCentroid( [0 0;1 1;1 0;0 1] )
%     Results:
%         cc = [0.5000    0.5000]
%         area = 0
%         cv = [0.5000    0.5000]
%     [cc,area,cv] = polyCentroid( [0 0 2;1 1 2;1 0 2;0 1 2] )
%     Results:
%         cc = [0.5000    0.5000    2.0000]
%         area = 0
%         cv = [0.5000    0.5000    2.0000]
%     [cc,area,cv] = polyCentroid( [0 0 2;1 1 2;1 0 2;0 1 2.01] )
%     Results:
%         cc = [0.5000    0.5000    2.0025]
%         area = 0.5036
%         cv = [0.5000    0.5000    2.0025]
%
%   See also: centroids, polyhedronCentroid


    if isempty(v)
        ca = [];
        area = 0;
        cv = [];
        return;
    end
    
    twoD = size(v,2)==2;
    almostTwoD = twoD || all(v(:,3)==v(1,3));
    if twoD
        v = [ v zeros( size(v,1), 1 ) ];
    end

    % The vertex centroid is well-defined.
    cv = sum( v, 1 )/size( v, 1 );

    if size(v,1) <= 2
        ca = cv;
        area = 0;
        return;
    end
    
    % Find the average of the vertexes and move the origin to there.
    v = v - repmat( cv, size(v,1), 1 );
    
%     dotprods = sum( v .* v([2:end 1],:), 2 );
    
    vv = v( [ (2:size(v,1)), 1 ], : );
    tc = (v + vv)/3;  % Locations of centroids of the triangles, relative to the vertex centroid.
    crossprods = cross( v, vv, 2 );
    if almostTwoD
        signs = sign(crossprods(:,3));
    end
    as2 = sqrt( sum( crossprods.^2, 2 ) );  % Twice the areas of the triangles.
    if almostTwoD
        as2 = as2 .* signs;
    end
    
    area = sum(as2);
    
    if area==0
        ca = cv;
    else
        % Sum of centroids, weighted by twice area.
        ca = sum( tc .* repmat( as2, 1, size( tc, 2 ) ), 1 );
        % Normalise by twice area and translate to original position.
        ca = ca/area + cv;
    end
    
    % Get actual area.
    area = area/2;
    
    if twoD
        % Cut off the third coordinate.
        ca = ca([1 2]);
        cv = cv([1 2]);
    end
end
