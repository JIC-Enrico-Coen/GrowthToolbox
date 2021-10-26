function [ipts,whichpoly,bcs] = projectPointsToMesh( vxs, polys, pts, origins )
%newpts = projectPointsToMesh( m, pts, origins )
%   Find the intersection with the polygon mesh defined by vxs and polys of
%   the semi-infinite ray from each origin through the corresponding point.

% 1. Exclude FEs in the wrong quadrant.

% 1a. Exclude FEs lying on the wrong side of the origin.

% 2. Transform everything remaining to move the infinite ray to the +Z
% axis.

% 3. Exclude all FEs whose AABB in XY does not enclose the line.

% 4. Do the full hit test for all remaining FEs.

% Initially we only need this to work for projection from the Z axis,
% perpendicular to that axis.

    TOLERANCE = 1e-5;
    numvxs = size(vxs,1);
    numpts = size(pts,1);
    dims = size(vxs,2);
    whichpoly = zeros( numpts, 1 );
    ipts = zeros( numpts, dims );
    bcs = zeros( numpts, dims );

    candidates = true( size(polys,1), 1 );
    for i=1:numpts
        o = origins(i,:);
        p = pts(i,:);
        op = p - o;
        newvxs = vxs - repmat( o, numvxs, 1 );
        
        % 1. Exclude FEs in the wrong quadrants.
        pos = (newvxs >= 0) == repmat( op>=0, numvxs, 1 );
        for j=1:dims
            posj = pos(:,j);
            candidates = candidates & any( posj( polys ), 2 );
        end
        
        % 1a. Exclude FEs lying on the wrong side of the origin.
        onrightside = dot( newvxs, repmat( op, numvxs, 1 ), 2 ) > -TOLERANCE;
        candidates = any( onrightside( polys ), 2 );
        if ~any(candidates)
            continue;
        end
        
        newpolys = polys(candidates,:);
        vxsmask = false(size(newvxs,1),1);
        vxsmask(newpolys(:)) = true;
        newvxs = newvxs(vxsmask,:);
        reindexvxs = zeros(size(vxsmask));
        reindexvxs(vxsmask) = 1:sum(vxsmask);
        newpolys = reindexvxs(newpolys);
        
        % 2. Transform everything remaining to move the infinite ray to the +Z
        % axis.
        phi = vecangle( op, [0 0 1] );
        if phi > 0
            theta = atan2( op(2), op(1) );
            ct = cos(theta);
            st = sin(theta);
            cp = cos(phi);
            sp = sin(phi);
            z = [ ct*sp, st*sp, cp ];
            y = [ -st, ct, 0 ];
            x = [ ct*cp, st*cp, -sp ];
            rot = [x;y;z]';
            newvxs = newvxs*rot;
            op = op*rot;
        end
        
        % 3. Exclude all FEs whose AABB in XY does not enclose the line.
        allpolys = reshape( newvxs(newpolys',:), size(newpolys,2), size(newpolys,1), dims );
        xmin = min( allpolys(:,:,1), [], 1 );
        xmax = max( allpolys(:,:,1), [], 1 );
        ymin = min( allpolys(:,:,2), [], 1 );
        ymax = max( allpolys(:,:,2), [], 1 );
        cand1 = (xmin <= TOLERANCE) & (xmax >= -TOLERANCE) & (ymin <= TOLERANCE) & (ymax >= -TOLERANCE);
        if ~any(cand1)
            continue;
        end
        newpolys = newpolys(cand1,:);
        candidates(candidates) = cand1;
        vxsmask = false(size(newvxs,1),1);
        vxsmask(newpolys(:)) = true;
        newvxs = newvxs(vxsmask,:);
        reindexvxs = zeros(size(vxsmask));
        reindexvxs(vxsmask) = 1:sum(vxsmask);
        newpolys = reindexvxs(newpolys);
        
        % 4. Do the full hit test for all remaining FEs.
        hits = false( size(newpolys,1), 1 );
        hit = false;
        for j=1:size(newpolys,1)
            [bc,baryCoords_err,n] = baryCoords( [ newvxs( newpolys(j,:), [1 2] ), zeros(3,1) ], [0 0 1], [0 0 0], false );
            [intersection,intbary] = lineTriangleIntersection( [0 0 0;op], newvxs( newpolys(j,:), : ), false );
            hits(j) = all(intbary >= -TOLERANCE) && (sum(intbary) > 1 - TOLERANCE);
            if hits(j)
                candidates(candidates) = hits;
                hit = true;
                break;
            end
        end
        if hit
            whichpoly(i) = find(candidates,1);
%             ipts(i,:) = intersection*rot;
            bcs(i,:) = intbary;
            ipts(i,:) = bcs(i,:)*vxs(polys(whichpoly(i),:),:);
        end
    end
end
