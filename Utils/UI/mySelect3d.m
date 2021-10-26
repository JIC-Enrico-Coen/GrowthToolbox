function [pt, bc, itemhit] = mySelect3d( hitObject, hitData )
%[pt, bc, faceiout] = mySelect3d( hitObject, hitData )
%   hitObject is assumed to be a handle to a patch.
%   hitData is the structure returned by a mouse click on the patch.
%   This procedure calculates which triangle was clicked on, and the
%   barycentric coordinates of the hit point with respect to three of the
%   vertexes of the patch, whose triangle encloses the point.

    pt = [];
    bc = [];
    itemhit = [];
    
    ax = ancestor( hitObject, 'axes' );
    stabbingLine = get( ax, 'CurrentPoint' );
    stabbingDir = stabbingLine(2,:) - stabbingLine(1,:);
    if isempty( hitData )
        stabPoint = stabbingLine(1,:);
    else
        stabPoint = hitData.IntersectionPoint;
    end
    obtype = get( hitObject, 'type' );
    if strcmp(obtype,'line') && strcmp(get(hitObject,'LineStyle'),'none');
        obtype = 'point';
    end
    
    switch obtype
        case 'patch'
            vxs = get( hitObject, 'Vertices' );
            faces = get( hitObject, 'Faces' );
        case 'line'
            xs = get( hitObject, 'Xdata' );
            ys = get( hitObject, 'Ydata' );
            zs = get( hitObject, 'Zdata' );
            % We assume that this is a single line object made up of
            % separate line segments.
            xs = reshape( xs, 3, [] );
            xs = xs(1:2,:);
            ys = reshape( ys, 3, [] );
            ys = ys(1:2,:);
            zs = reshape( zs, 3, [] );
            zs = zs(1:2,:);
            vxs = [ xs(:), ys(:), zs(:) ];
            numedges = size(xs,2);
            f = (1:numedges)' * 2;
            faces = [ f-1, f ];
        case 'point'
            xs = get( hitObject, 'Xdata' );
            ys = get( hitObject, 'Ydata' );
            zs = get( hitObject, 'Zdata' );
            vxs = [ xs(:), ys(:), zs(:) ];
    end
    
    [bestStabValue,bestAxis] = max( abs( stabbingDir ) );
    otheraxes = mod( [ bestAxis, bestAxis+1 ], 3 ) + 1;
    if bestStabValue==0
        % No stabbing direction, give up.
        return;
    end

    % Project the vertices and the stabbing line onto the plane
    % perpendicular to bestAxis, along stabbingDir.
    bestStabValue = stabbingDir(bestAxis);
    kv = vxs(:,bestAxis)/bestStabValue;
    vxs2 = vxs(:,otheraxes) - kv*stabbingDir(otheraxes);
    ks = stabPoint(bestAxis)/bestStabValue;
    stabPoint2 = stabPoint(otheraxes) - ks*stabbingDir(otheraxes);

    if strcmp(obtype,'point')
        distances = pointPointDistance( vxs2, stabPoint2 );
        [~,itemhit] = min(distances);
        pt = vxs(itemhit,:);
        bc = 1;
        return;
    end


    % Check: vxs2err should be zero to within rounding error.
    % vxs2err = max( abs(stabPoint(bestAxis) - ks*bestStabValue), max( abs( vxs(:,bestAxis) - kv*bestStabValue ) ) )

    % Fast test to exclude polygons by bounding box.
    xs = nan(size(faces));
    xs( ~isnan(faces) ) = vxs2(faces(~isnan(faces)),1);
    ys = nan(size(faces));
    ys( ~isnan(faces) ) = vxs2(faces(~isnan(faces)),2);

%     xs = reshape( vxs2(faces,1), size(faces) );
%     ys = reshape( vxs2(faces,2), size(faces) );
    tol = 1e-8;
    candidates = any( xs < stabPoint2(1)+tol, 2 ) & any( xs > stabPoint2(1)-tol, 2 ) ...
                 & any( ys < stabPoint2(2)+tol, 2 ) & any( ys > stabPoint2(2)-tol, 2 );
    candIndexes = find(candidates)';
    if isempty( candIndexes )
        return;
    end
    switch obtype
        case 'patch'
            % For each candidate, do an exact test.
            stillCandidates = true(1,length(candIndexes));
            numcorners = size(faces,2);
            bcs = zeros(length(candIndexes),numcorners);
            intersections = zeros(length(candIndexes),3);
            distances = zeros(length(candIndexes),1);
            if isempty(candIndexes)
                return;
            end
            for i=1:length(candIndexes)
                ci = candIndexes(i);



%                     [bc,baryCoords_err,n] = baryCoords2( vxs, n, v );
%                     if size(poly,1)==3
%                         bc = baryCoords( poly, [], stabPoint );
%                     else
%                         [inside,bc] = pointInPoly3D( stabPoint, poly );
%                     end
%                     


                vis = faces(ci,:);
                vis(isnan(vis)) = [];
                [inside,bc] = pointInPoly( stabPoint2, vxs2(vis,:) );
                if ~inside
                    stillCandidates(i) = false;
                else
                    bcs(i,1:length(bc)) = bc;
                    intersections(i,:) = bc * vxs(vis,:);
                    distances(i) = bc * kv(vis);
                end
            end
            candIndexes = candIndexes(stillCandidates);
            bcs = bcs(stillCandidates,:);
            intersections = intersections(stillCandidates,:);
            distances = distances(stillCandidates);

            % Choose the point having the smallest value of kv.
            [~, mdi] = min( distances );
            pt = intersections(mdi,:);
            bc = bcs(mdi,:);
            itemhit = candIndexes(mdi);
            bc = bc(~isnan(faces(itemhit,:)));
        case 'line'
            distances = zeros(length(candIndexes),1);
            bcs = zeros(length(candIndexes),2);
            for i=1:length(candIndexes)
                ci = candIndexes(i);
                [distances(i),~,bcs(i,:)] = pointLineDistance( vxs2(faces(ci,:),:), stabPoint2, false );
            end
            [mind,mini] = min(distances);
            bc = bcs(mini,:);
            pt = bc * vxs( [2*ci-1,2*ci], : );
            itemhit = candIndexes(mini);
    end
end
