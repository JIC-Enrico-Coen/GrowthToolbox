function [pi,hitCoords,hitPoint] = findHitPatch( p, hitLine )
%[pi,paramcoordshitPointpt] = findHitPatch( p, hitLine )
%   Given a patch handle p and a hit line, find which polygon of the path
%   is hit by the line.  The polygons are assumed to be either all
%   triangles or all quadrilaterals.
% WORK IN PROGRESS

    x = get( p, 'XData' );
    y = get( p, 'YData' );
    z = get( p, 'ZData' );
    numvxs = size(x,1);
    numpolys = size(x,2);
    pts = zeros(numpolys,3);
    bcpts = zeros(numpolys,3);
    dots = zeros(numpolys,1);
    hitvector = hitLine(2,:) - hitLine(1,:);
    if numvxs==3
        for i=1:numpolys
            [pts(i,:),bcpts(i,:)] = lineTriangleIntersection( hitLine, [x(:,i),y(:,i),z(:,i)] );
            dots(i) = sum( pts(i,:) .* hitvector );
        end
        [mindot,pi] = min( dots );
        hitPoint = pts(pi,:);
        hitCoords = bcpts(pi,:);
        hitCoords = normaliseBaryCoords( hitCoords );
    else
        % Assume numpoly==4.
    end
end
