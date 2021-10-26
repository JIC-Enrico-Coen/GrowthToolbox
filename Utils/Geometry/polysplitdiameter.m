function [c,v,mindist,t] = polysplitdiameter( vxs )
%[c,v] = polysplitdiameter( vxs )
%   Given an N*2 matrix of vertexes of a 2D or 3D polygon, find the centroid c of
%   the polygon and a unit vector v, such that the distance from c along v
%   to an edge of the polygon is minimised.

    numvxs = size(vxs,1);
    dims = size(vxs,2);
    if dims==2
        vxs = [ vxs, zeros(numvxs,1) ];
    end
    rvxs = vxs(2:numvxs,:) - repmat(vxs(1,:),numvxs-1,1);
    centroids = (rvxs(1:numvxs-2,:) + rvxs(2:numvxs-1,:))*(1/3);
%     areas1 = abs( rvxs(1:numvxs-2,2) .* rvxs(2:numvxs-1,1) ...
%                   - rvxs(1:numvxs-2,1) .* rvxs(2:numvxs-1,2) );
    areas = sqrt( sum( cross( rvxs(1:numvxs-2,:), rvxs(2:numvxs-1,:), 2 ).^2, 2 ) );
    % rc = sum([centroids(:,1) .* areas, centroids(:,2) .* areas],1)/sum(areas);
    rc = sum(centroids .* repmat(areas,1,size(centroids,2)),1)/sum(areas);
    % c = [ vxs(1,1) + rc(:,1), vxs(1,2) + rc(:,2) ];
    c = repmat(vxs(1,:),size(rc,1),1) + rc;
    
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
    if dims==2
        c = c([1 2]);
        v = v([1 2]);
    end
end
