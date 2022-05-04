function [c,v,mindist,t] = polysplitdiameter( vxs )
%[c,v] = polysplitdiameter( vxs )
%   Given an N*D matrix of vertexes of a 2D or 3D polygon, find the centroid c of
%   the polygon and a unit vector v, such that the distance from c along v
%   to an edge of the polygon is minimised.

    numvxs = size(vxs,1);
    dims = size(vxs,2);
    if dims < 3
        vxs = [ vxs, zeros(numvxs,3-dims) ];
    elseif dims > 3
        vxs = vxs(:,1:3);
    end
    
    % Calculate the vector from vertex 1 to each of the other vertexes.
    rvxs = vxs(2:numvxs,:) - repmat(vxs(1,:),numvxs-1,1);
    
    % Find the centroid of each triangle formed from vertex 1 and vertexes
    % i and i+1.
    centroids = (rvxs(1:numvxs-2,:) + rvxs(2:numvxs-1,:))*(1/3);
    
    % Find the areas of these triangles.
    areas = sqrt( sum( cross( rvxs(1:numvxs-2,:), rvxs(2:numvxs-1,:), 2 ).^2, 2 ) );
    
    % Take the sum of the centroids, weighted by the areas.
    rc = sum(centroids .* repmat(areas,1,size(centroids,2)),1)/sum(areas);
    
    % Add back vertex 1. This is the centroid of the polygon.
    c = vxs(1,:) + rc;
    
    [mindist,t] = pointLineDistance( vxs([1,2],:), c );
    for i=2:numvxs-1
        [d,pp] = pointLineDistance( vxs([i,i+1],:), c );
        if d < mindist
            mindist = d;
            t = pp;
        end
    end
    v = t-c;
    n = norm(v);
    if n > 0
        v = v/n;
    end
    if dims < 3
        c = c(1:dims);
        v = v(1:dims);
    end
end
