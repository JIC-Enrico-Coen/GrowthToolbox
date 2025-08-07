function intersections = planeBoxIntersection( planeNormal, planePoint, bbox )
% intersections = planeBoxIntersection( planeNormal, planePoint, bbox )
% Find the intersection of every edge of the box with the specified plane,
% retaining only those that lie within the box. The points are returned in
% clockwise order relative to the planeNormal by the right-hand rule. Thus
% they can be plotted as a poly gon by e.g.:
%
%   plot3( pts([1:end 1],1), pts([1:end 1],2), pts([1:end 1],3), '.-' );

    tol = 1e-5;

    % Find the intersection with each edge, indefinitely prolonged.
    edgecodes = zeros( 12, 3 );
    intersections = zeros( 12, 3 );
    intersectionRatios = zeros( 12, 1 );
    ii = 0;
    for a = 1:3
        for b = 1:2
            for c = 1:2
                [a2,a3] = othersOf3( a );
                p1 = [ bbox(1,a), bbox(b,a2), bbox(c,a3) ];
                p1([a a2 a3]) = p1;
                p2 = p1;
                p2(a) = bbox(2,a);
                ii = ii+1;
                edgecodes(ii,:) = [a,b,c];
                [ intersections(ii,:), intersectionRatios(ii) ] = lineplaneIntersection( p1, p2, planeNormal, planePoint );
            end
        end
    end
    
    % Exclude intersections outside the bounding box.
    withinBox = (intersectionRatios >= 0) & (intersectionRatios <= 1);
    intersections = intersections( withinBox, : );
    
    % Move everything that is very close to the bounding box exactly onto
    % it.
    for ax=1:3
        for sgn = 1:2
            foo = abs( intersections(:,ax) - bbox(sgn,ax) ) < tol;
            intersections(foo,ax) = bbox(sgn,ax);
        end
    end
    
    % Eliminate near-duplicates.
    intersections = uniquetol( intersections, tol, 'ByRows', true );
    
    % Now express the intersections in terms of the plane basis, and
    % calculate angles from the centre point, in order to list them in
    % cyclic order.
    
    J = makebasis( planeNormal );
    is2D = (intersections-planePoint)*J;
    angles = atan2( is2D(:,3), is2D(:,2) );
    [angles1,p] = sort( angles );
    intersections = intersections(p,:);
    
    TESTING = false;
    if TESTING && ~isempty( intersections )
        [figure,ax] = getFigure();
        plotpts( ax, intersections([1:end],:), '.-g', 'LineWidth', 2, 'MarkerSize', 10 );
        axis equal
        hold on;
        plotpts( ax, intersections(1,:), '.-r', 'LineWidth', 2, 'MarkerSize', 20 );

        bboxvxs = zeros(9,3);
        vi = 0;
        for x=1:2
            for y=1:2
                for z=1:2
                    vi = vi+1;
                    bboxvxs(vi,:) = [ bbox(x,1), bbox(y,2), bbox(z,3) ];
                end
            end
        end
        bboxvxs(9,:) = NaN;
        plotpts( ax, bboxvxs( [ 1 2 4 3 1 9 5 6 8 7 5 9 1 5 9 2 6 9 3 7 9 4 8 ], : ), '-k', 'LineWidth', 1, 'Marker', 'none' );
        hold off;
    end
end
