function m = makesecondlayeruniversal( m, d )
%makesecondlayeruniversal( m, d )
%   An experimental method of extending a division of the border of a
%   region to a triangulation of its interior.
%   Initial implementation is on the plane, but it should generalise to the
%   surface of a curved mesh.

    draw = true;
    progressivedraw = true;  % If true, draw as we go. If false, only draw at the end.

    % Get the borders of the mesh.  We assume for the moment that it has at
    % least one, and e.g. it is not a sphere.
    [vs,es,perms] = getMeshBorders( m );

    % For each border, lay out a series of points at approximately the
    % required distance d.
    ptloops = {};
    feloops = {};
    bcloops = {};
    for i=1:length(vs)
        vsi = vs{i};
        esi = es{i};
        vpts = m.nodes([vsi; vsi(1)],:);
        edgelengths = sqrt( sum( (vpts([2:end 1],:) - vpts).^2, 2 ) );
        dists = [ 0; cumsum( edgelengths ) ];
        numpts = max( 3, round(dists(end)/d) );
        delta = dists(end)/numpts;
        j = 1;
        k = 1;
        pts = zeros(numpts,3);
        fes = zeros(numpts,1);
        bcs = zeros(numpts,3);
        pts(1,:) = vpts(1,:);
        fes(1) = m.edgecells( esi(1), 1 );
        bcs(1,find(m.tricellvxs(fes(1),:)==vsi(1),1)) = 1;
        while j < numpts
            totd = delta*j;
            while dists(k) < totd
                k = k+1;
            end
            j = j+1;
            fes(j) = m.edgecells( esi(k-1), 1 );
            vci = find(m.tricellvxs(fes(j),:)==vsi(k-1),1);
            b = (totd-dists(k-1))/(dists(k)-dists(k-1));
            a = 1-b;
            bcs(j,vci) = a;
            vci1 = 1+mod(vci,3);
            bcs(j,vci1) = b;
            pts(j,:) = a*vpts(k-1,:) + b*vpts(k,:);
            % bcs(j,1+mod(vci1,3)) = 0;
        end
        ptloops{end+1} = pts;
        feloops{end+1} = fes;
        bcloops{end+1} = bcs;
    end

    if draw
        figure(1);
        ax = gca;
        cla(ax);
        axis equal;
    end

    if draw && progressivedraw
        % Draw the initial boundaries.
        for i=1:length(ptloops)
            pts = ptloops{i};
            line( pts([1:end 1],1), pts([1:end 1],2), pts([1:end 1],3), 'Parent', ax, 'LineStyle', '-', 'Marker', 'o' );
        end;
        % axis equal
    end
    
    if isempty(ptloops)
        % Choose a point on the surface.
        fe = 1;
        bc = [1 1 1]/3;
        pt = baryToGlobalCoords( fe, bc, m.nodes, m.tricellvxs );
        % Extend lines in six directions.
        n = m.unitcellnormals(fe,:);
        [v1,v2] = makeframe(n);
        v1 = v1*d;
        v2 = v2*d;
        numpts = 6;
        s60 = sqrt(0.75);
        c = [0.5 -0.5 -1 -0.5 0.5]';
        s = [-s60 -s60 0 s60 s60]';
        offsets = [ v1; repmat(v1,5,1).*repmat(c,1,3) + repmat(v2,5,1).*repmat(s,1,3) ];
        pts = zeros(numpts,3);
        fes = zeros(numpts,1);
        bcs = zeros(numpts,3);
        for i=1:numpts
            [pts(i,:),fes(i),bcs(i,:)] = projectToMesh( pt + offsets(i,:), m, fe );
        end
        numallpts = 7;
        allpts = [pt; pts; zeros( numallpts, 3 )];
        allfes = [fe; fes; zeros( numallpts, 1 )];
        allbcs = [bc; bcs; zeros( numallpts, 3 )];
        numtrivxs = 6;
        trivxs = [[1 2 3;
                   1 3 4;
                   1 4 5;
                   1 5 6;
                   1 6 7;
                   1 7 2 ];
                  zeros(numtrivxs,3) ];
        trivxs(:,[2 3]) = trivxs(:,[3 2]);
        indexes = 2:numallpts;
        if draw && progressivedraw
            local_plotlines( allpts, [1 1 1 1 1 1 2 3 4 5 6 7], [2 3 4 5 6 7 3 4 5 6 7 2], ax );
            local_plotvxs( allpts, 1:numallpts, ax );
            local_plotcentre( allpts, trivxs(1:numtrivxs,:), ax );
        end
    else
        pts = ptloops{1};
        fes = feloops{1};
        bcs = bcloops{1};
        ptloops(1) = [];
        feloops(1) = [];
        bcloops(1) = [];
        trivxs = zeros(size(pts,1)*2,3);
        numallpts = size(pts,1);
        allpts = [ pts; zeros( numallpts, 3 ) ];
        allfes = [ fes; zeros( numallpts, 1 ) ];
        allbcs = [ bcs; zeros( numallpts, 3 ) ];
        numtrivxs = 0;
        indexes = 1:numallpts;
    end
    
    % Set up working variables.
    deltas = pts([2:end 1],:) - pts;
    avsz = sum(sqrt(sum(deltas.^2,2)))/size(deltas,1);
    minsize = avsz*1;
    maxsize = avsz*1.1;  % Er, wut??  minsize==maxsize makes no sense.
    

    % Calculate the exterior angle between each boundary edge and the next.
    normals = normalToMesh( pts, fes, bcs, m );
    allangles = surfaceangle( deltas([end 1:(end-1)],:), deltas, normals );
    % allangles = vecangle( deltas([end 1:(end-1)],:), deltas, [0 0 1] );
    
    % Perform the algorithm.
    niters = 0;
    while size(pts,1) > 3
%         alldeltascheck = pts([2:end 1],:) - pts;
%         deltaerror = max(abs(deltas-alldeltascheck))
%         allanglescheck = surfaceangle( deltas([end 1:(end-1)],:), deltas, normals );
%         angleerror = max(abs(allangles-allanglescheck))
%         if (max(abs(deltaerror(:))) > 0.1) || (max(abs(angleerror)) > 0.1)
%             error ('error' );
%         end
        niters = niters+1;
        if mod(niters,100)==0
            fprintf( 1, '%s: %d iterations, %d points remaining\n', mfilename(), niters, size(pts,1) );
        end
        if mod(niters,1000)==0
            xxxx = 1;
        end

        % Choose the place to add triangles: the point where the edges
        % meeting at it make the smallest angle.
        numpts = size(pts,1);
        [~, maxi] = max( allangles );
        ang = pi-allangles(maxi);
        % The three points are at indexes ai, bi, and ci in the current pts
        % array, positions a, b, and c, and indexes i1, i2, and i3 in the
        % array of all points.
        bi = maxi;
        if bi==1
            ai = numpts;
        else
            ai = bi-1;
        end
        if bi==numpts
            ci = 1;
        else
            ci = bi+1;
        end
        a = pts(ai,:);
        b = pts(bi,:);
        c = pts(ci,:);
        i1 = indexes(ai);
        i2 = indexes(bi);
        i3 = indexes(ci);
        
        % Decide how many triangles to split the angle into.
        sixths = ang*6/pi - 0.15;
        numnewpts = max( 0, ceil( (sixths-3)/2 ) );
        if (numnewpts==0) && (sixths > 1.5) && (sqrt(sum((c-a).^2)) > maxsize*1.8)
            numnewpts = 1;
        end
        
        if (numnewpts==0) && (numpts==3)
            break;
        end
        
        % Calculate the locations of the new points.
        newpts = zeros( numnewpts, 3 );
        newfes = zeros( numnewpts, 1 );
        newbcs = zeros( numnewpts, 3 );
        d = min( maxsize, max( minsize, (norm(c-b) + norm(b-a))/2 ) );
        for i=1:numnewpts
            newpt = rotVec( a-b, [0 0 0], normals(bi,:), -ang*i/(numnewpts+1) );
            newpt = newpt*(d/norm(newpt));
            [newpts(i,:),newfes(i),newbcs(i,:)] = projectToMesh( b + newpt, m, fes([ai bi ci]) );
        end
        
        % See if we've joined up with another component of the border.
        borderjoin = false;
        if ~isempty(allpts) && (numnewpts > 0)
            % Find the closest distance between any new point and any point
            % on another component of the border.
            mind = zeros(1,numnewpts);
            mini = zeros(1,numnewpts);
            amindd = zeros(1,length(ptloops));
            aminii = zeros(1,length(ptloops));
            bminii = zeros(1,length(ptloops));
            if length(ptloops) > 1
                xxxx = 1;
            end
            for j=1:length(ptloops)
                p2 = ptloops{j};
                for i=1:numnewpts
                    [mind(i), mini(i)] = min( sum( (p2 - repmat( newpts(i,:), size(p2,1), 1 )).^2, 2 ) );
                end
                [amindd(j),aminii(j)] = min(mind);
                bminii(j) = mini(aminii(j));
            end
            [mindd,pminii] = min(amindd);
            
            
            % If we are close enough, merge the other border component with
            % the current one.
            if sqrt(mindd) <= maxsize
                pts2 = ptloops{pminii};
                fes2 = feloops{pminii};
                bcs2 = bcloops{pminii};
                minii = aminii(pminii);
                ptloops(pminii) = [];
                feloops(pminii) = [];
                bcloops(pminii) = [];
                % Move the selected point to coincide with the near point
                % on the other border component.
                % newpti = mini(minii);
                newpti = bminii(pminii);
                pindexes = [newpti:size(pts2,1), 1:newpti];
                newpts = pts2(pindexes,:);
                newfes = fes2(pindexes);
                newbcs = bcs2(pindexes,:);
                numnewpts = size(newpts,1);
                borderjoin = true;
                newdeltas = [ newpts; pts(bi,:) ] - [ pts(bi,:); newpts ];
                newnormals = normalToMesh( newpts, newfes, newbcs, m );
                newangles = surfaceangle( [deltas(ai,:); newdeltas], ...
                                          [newdeltas; deltas(bi,:)], ...
                                          [normals(bi,:); newnormals; normals(bi,:)] );
                pts = [ pts(1:bi,:); newpts; pts(bi:end,:) ];
                fes = [ fes(1:bi); newfes; fes(bi:end) ];
                bcs = [ bcs(1:bi,:); newbcs; bcs(bi:end,:) ];
                normals = [ normals(1:bi,:); newnormals; normals(bi:end,:) ];
                deltas = [ deltas(1:(bi-1),:); newdeltas; deltas(bi:end,:) ];
                allangles = [ allangles(1:(bi-1)); newangles; allangles((bi+1):end) ];
                % allpts = [ allpts; newpts ];
                newnumallpts = numallpts+numnewpts-1;
                if newnumallpts > size(allpts,1)
                    allpts = [ allpts; zeros( size(allpts) ) ];
                    allfes = [ allfes; zeros( size(allfes) ) ];
                    allbcs = [ allbcs; zeros( size(allbcs) ) ];
                end
                allpts( (numallpts+1):newnumallpts, : ) = newpts(1:(end-1),:);
                allfes( (numallpts+1):newnumallpts, : ) = newfes(1:(end-1));
                allbcs( (numallpts+1):newnumallpts, : ) = newbcs(1:(end-1),:);
                newindexes = numallpts+[1:(numnewpts-1) 1];
                numallpts = newnumallpts;
                indexes = [ indexes(1:bi), newindexes, indexes(bi:end) ];
                if draw && progressivedraw
                    local_plotlines( allpts, i2, newindexes(1), ax );
                end
                pts2 = [];
                fes2 = [];
                bcs2 = [];
            end
        end
        
        if ~borderjoin
            % Calculate the new normals, deltas, angles, indexes, and triangles.
            newnormals = normalToMesh( newpts, newfes, newbcs, m );
            % allpts = [ allpts; newpts ];
            newnumallpts = numallpts+numnewpts;
            if newnumallpts > size(allpts,1)
                allpts = [ allpts; zeros( size(allpts) ) ];
                allfes = [ allfes; zeros( size(allfes) ) ];
                allbcs = [ allbcs; zeros( size(allbcs) ) ];
            end
            pindexes = (numallpts+1):newnumallpts;
            allpts( pindexes, : ) = newpts;
            allfes( pindexes, : ) = newfes;
            allbcs( pindexes, : ) = newbcs;
            newindexes = numallpts+(1:numnewpts);
            numallpts = newnumallpts;
            newdeltas = [ newpts; c ] - [ a; newpts ];
            if ai<ci
                pts = [pts(1:ai,:); newpts; pts(ci:end,:)];
                fes = [fes(1:ai,:); newfes; fes(ci:end,:)];
                bcs = [bcs(1:ai,:); newbcs; bcs(ci:end,:)];
                if ai==1
                    newangles = surfaceangle( [deltas(end,:); newdeltas], [newdeltas; deltas(ci,:)], [ normals(ai,:); newnormals; normals(ci,:) ] );
                else
                    newangles = surfaceangle( [deltas(ai-1,:); newdeltas], [newdeltas; deltas(ci,:)], [ normals(ai,:); newnormals; normals(ci,:) ] );
                end
                normals = [normals(1:ai,:); newnormals; normals(ci:end,:)];
                allangles = [ allangles(1:(ai-1)); newangles; allangles((ci+1):end) ];
                deltas = [ deltas(1:(ai-1),:); newdeltas; deltas(ci:end,:) ];
                indexes = [ indexes(1:ai), newindexes, indexes(ci:end) ];
            else
                pts = [ pts(ci:ai,:); newpts ];
                fes = [ fes(ci:ai,:); newfes ];
                bcs = [ bcs(ci:ai,:); newbcs ];
                newangles = surfaceangle( [deltas(ai-1,:); newdeltas], [newdeltas; deltas(ci,:)], [ normals(ai,:); newnormals; normals(ci,:) ] );
                normals = [ normals(ci:ai,:); newnormals ];
                allangles = [ newangles(end); allangles((ci+1):(ai-1)); newangles(1:(end-1)) ];
                % allangles = [ allangles(ci:(ai-2)); newangles ];
                deltas = [ deltas(ci:(ai-1),:); newdeltas ];
                indexes = [ indexes(ci:ai), newindexes ];
            end
            newtriangles = [ ones(numnewpts+1,1)*i2, [newindexes'; i3], [i1; newindexes'] ];
            % trivxs = [ trivxs; newtriangles ];
            newnumtrivxs = numtrivxs+size(newtriangles,1);
            if newnumtrivxs > size(trivxs,1)
                trivxs = [ trivxs; zeros( size(trivxs) ) ];
            end
            trivxs( (numtrivxs+1):newnumtrivxs, : ) = newtriangles;
            numtrivxs = newnumtrivxs;

            if draw && progressivedraw
                local_plotlines( allpts, [i1 newindexes], [newindexes i3], ax );
                local_plotlines( allpts, repmat( i2, 1, numnewpts), newindexes, ax );
%                 if any(sum(allpts(newindexes,:).^2,2) < 0.1)
%                     error('error');
%                 end
                local_plotvxs( allpts, newindexes, ax );
                local_plotcentre( allpts, newtriangles, ax );
            end
        end
        
        if draw && progressivedraw
            drawnow;
        end
    end
        
    if size(pts,1)==3
        trivxs(numtrivxs+1,:) = indexes;
        numtrivxs = numtrivxs+1;
        if draw && progressivedraw
            local_plotcentre( allpts, indexes, ax );
            drawnow;
        end
    elseif size(pts,1)==4
        d13sq = sum( (pts(1,:)-pts(3,:)).^2 );
        d24sq = sum( (pts(2,:)-pts(4,:)).^2 );
        if d13sq < d24sq
            trivxs(numtrivxs+1,:) = indexes([2 3 1]);
            trivxs(numtrivxs+2,:) = indexes([1 3 4]);
            if draw && progressivedraw
                local_plotlines( allpts, indexes(1), indexes(3), ax );
                local_plotcentre( allpts, indexes([2 3 1; 1 3 4]), ax );
                drawnow;
            end
        else
            trivxs(numtrivxs+1,:) = indexes([1 2 4]);
            trivxs(numtrivxs+2,:) = indexes([4 2 3]);
            if draw && progressivedraw
                local_plotlines( allpts, indexes(2), indexes(4), ax );
                local_plotcentre( allpts, indexes([1 2 4; 4 2 3]), ax );
                drawnow;
            end
        end
        numtrivxs = numtrivxs+2;
    else
        trivxs(end+1,:) = indexes;
    end
    trivxs( (numtrivxs+1):end, : ) = [];
    allpts( (numallpts+1):end, : ) = [];
    allfes( (numallpts+1):end ) = [];
    allbcs( (numallpts+1):end, : ) = [];
    
    if draw && ~progressivedraw
        local_plotlines( allpts, trivxs(:,1), trivxs(:,2), ax );
        local_plotlines( allpts, trivxs(:,2), trivxs(:,3), ax );
        local_plotlines( allpts, trivxs(:,3), trivxs(:,1), ax );
        local_plotcentre( allpts, trivxs, ax );
        axis equal

%         for i=1:size(trivxs,1)
%             local_plotcentre( allpts, trivxs(i,:), ax );
%         end
    end
    
    celllayer = dualTriMesh( allpts, trivxs, draw );
    numcells = length(celllayer.cells);
    numvxs = size(celllayer.cell3dcoords,1);
    fes = zeros( numvxs, 1 );
    bcs = zeros( numvxs, 3 );
    for i=1:numvxs
        [ fes(i), bcs(i,:), bcerr, abserr ] = findFE( m, celllayer.cell3dcoords(i,:) );  % Could supply hints.
    end
    celllayer.vxFEMcell = fes;
    celllayer.vxBaryCoords = bcs;
    celllayer.side = true(numcells,1);
    celllayer.cellcolor = [];
    
    m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    m.secondlayer = setFromStruct( m.secondlayer, celllayer );
    m.secondlayer.cellcolor = ...
        randcolor( numcells, ...
             m.globalProps.colorparams(1,[1 2 3]), ...
             m.globalProps.colorparams(1,[4 5 6]) );
end

function local_plottri( allpts, ixs, ax )
    alpha = 0;
    beta = 1-alpha;
    for k=1:size(ixs,1)
        p = allpts( ixs(k,[1 2 3 1]), : );
        centroid = sum(p,1)/size(p,1);
        p = alpha*p + beta*repmat(centroid,size(p,1),1);
        line( p(:,1), p(:,2), p(:,3), 'Parent', ax, 'LineStyle', '-', 'Marker', 'o' );
    end
end

function local_plotcentre( allpts, ixs, ax )
    for k=1:size(ixs,1)
        p = allpts( ixs(k,[1 2 3]), : );
        centroid = sum(p,1)/size(p,1);
        line( [centroid(1); centroid(1)], ...
              [centroid(2); centroid(2)], ...
              [centroid(3); centroid(3)], ...
              'Parent', ax, 'LineStyle', 'none', 'Marker', 'o' );
    end
end

function local_plotvxs( allpts, vxs, ax )
    line( [allpts(vxs,1)'; allpts(vxs,1)'], ...
          [allpts(vxs,2)'; allpts(vxs,2)'], ...
          [allpts(vxs,3)'; allpts(vxs,3)'], ...
          'Parent', ax, 'LineStyle', 'none', 'Marker', 'o' );
end

function local_plotlines( allpts, starts, ends, ax )
    line( [allpts(starts,1)'; allpts(ends,1)'], ...
          [allpts(starts,2)'; allpts(ends,2)'], ...
          [allpts(starts,3)'; allpts(ends,3)'], ...
          'Parent', ax, 'LineStyle', '-', 'Marker', 'none' );
end

function n = normalToMesh( p, fe, bc, m )
    n = m.unitcellnormals(fe,:);
end

function [q,ci,bc] = projectToMesh( p, m, hint )
    [ ci, bc, bcerr, abserr ] = findFE( m, p, 'hint', hint );
    q = baryToGlobalCoords( ci, bc, m.nodes, m.tricellvxs );
end




