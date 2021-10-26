function g = gridFromPolygon( polygon, nc1 )
%g = gridFromPolygon( polygon, resolution )
%       cells(:).vxs(:)
%       vxFEMcell(:)
%       vxBaryCoords(:,1:3)
%       cell3dcoords(:,1:3)

    g = [];

% Set g.cells(:}.vxs to the list of vertexes for each cell.
% g.cell3dcoords is the positions of all vertexes.

    numpolypts = size(polygon,1);
    xylo = min(polygon,[],1);
    xyhi = max(polygon,[],1);
    bboxsize = xyhi-xylo;
    bboxcentre = (xyhi+xylo)/2;
    celldiam = ( max(bboxsize)/nc1 );
    nc = ceil( bboxsize/celldiam );
    semidiam = nc*celldiam/2;
    
    polygon1 = (polygon + repmat( semidiam-bboxcentre, numpolypts, 1 ))/celldiam;

    xx = 0:nc(1);
    yy = 0:nc(2);
    xxx = repmat(xx', 1, length(yy));
    yyy = repmat(yy, length(xx), 1);
    
    % We now have to determine which grid lines cut the edges of the
    % polygon, and where.
    
    interps = cell(numpolypts,1);
    numinterppts = zeros(numpolypts,1);
    for i=1:numpolypts
        j = 1+mod(i,numpolypts);
        newpts = interpolateGrid( polygon1(i,:), polygon1(j,:) );
        if size(newpts,1) >= 2
            % Duplicates will happen if a polygon edge passes exactly
            % through a grid point. We must eliminate them.
            dups = all(newpts==newpts([2:end 1],:), 2);
            newpts(dups,:) = [];
        end
        interps{i} = newpts;
        numinterppts(i) = size( newpts, 1 );
    end
    
    polygon2 = zeros( size(polygon1,1)+sum(numinterppts), 2 );
    pg2i = 0;
    for i=1:numpolypts
        pg2i = pg2i+1;
        polygon2(pg2i,:) = polygon1(i,:);
        polygon2((pg2i+1):(pg2i+numinterppts(i)),:) = interps{i};
        pg2i = pg2i+numinterppts(i);
    end
    
    ongrid = polygon2==round(polygon2);
    ongrideither = any(ongrid,2);
    firstongrid = find(ongrideither,1);
    polygon2 = polygon2( [firstongrid:end 1:firstongrid], : );
    ongrid = ongrid( [firstongrid:end 1:firstongrid], : );
    ongrideither = ongrideither( [firstongrid:end 1:firstongrid] );
    starts = ongrideither(1:(end-1));
    ends = ongrideither(2:end);
    
    % Make all grid cells.
    % For each string of vertexes starts(i):ends(i), find the grid cell
    % they all lie in and split it.  Ignore thge possibility of multiple
    % splits for now.
    
    
    
    
    plotpts(polygon2,'.-k');
    hold on;
    plotpts(polygon2(ongrideither,:),'.r', 'MarkerSize', 15);
    plotpts([xxx(:) yyy(:)],'.g' );
    hold off;
    axis equal;
end

function crosses = interpolate1D( p1, p2 )
% Assumes the grid is on integer coordinates.
    
    q1 = min(p1,p2);
    q2 = max(p1,p2);
    flip = q1==p2;
    crosses = ceil(q1):floor(q2);
    if isempty(crosses)
        return;
    end
    if crosses(1)==p1
        crosses(1) = [];
    end
    if isempty(crosses)
        return;
    end
    if crosses(end)==p2
        crosses(end) = [];
    end
    if flip
        crosses = crosses( end:-1:1 );
    end
end

function newpoints = interpolateGrid( p1, p2 )
% Assumes the grid is on integer coordinates.

    xcrosses = interpolate1D( p1(1), p2(1) );
    xfrac = (xcrosses-p1(1))/(p2(1)-p1(1));
    xycrosses = p1(2) + xfrac*(p2(2)-p1(2));
    
    ycrosses = interpolate1D( p1(2), p2(2) );
    yfrac = (ycrosses-p1(2))/(p2(2)-p1(2));
    yxcrosses = p1(1) + yfrac*(p2(1)-p1(1));
    
    newpoints = [ xcrosses(:) xycrosses(:); yxcrosses(:) ycrosses(:) ];
    newpoints = sortrows(newpoints);
end
