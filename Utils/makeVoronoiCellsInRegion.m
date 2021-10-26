function [cells,cellvxs,centres] = makeVoronoiCellsInRegion( varargin )
%[cells,cellvxs,centres] = makeVoronoiEllipse( ... )
%   Make a centroidal Voronoi tessellation of the given axis-aligned
%   ellipse, with n cells. bbox gives the rectangle as [xlo, xhi, ylo,
%   yhi].

    cells = {};
    cellvxs = [];
    centres = [];

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'numcells', [], 'numiters', 10, 'mode', [], 'bbox', [], 'vxs', [], 'axis', [], 'subdivideedge', true );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'numcells', 'numiters', 'mode', 'bbox', 'vxs', 'axis', 'subdivideedge' );
    if ~ok, return; end
    s
    
    if isempty( s.numcells ) || isempty( s.mode )
        return;
    end
    
    switch s.mode
        case 'rectangle'
            if isempty( s.bbox )
                return;
            end
            centres = randInRectangle( s.numcells, s.bbox );
            userboundary = s.bbox;
            boundary = s.bbox( [ 1 3; 2 3; 2 4; 1 4 ] );
        case 'ellipse'
            if isempty( s.bbox )
                return;
            end
            [centres,semiaxes,centre] = randInEllipse( s.numcells, s.bbox );
            cellarea = (semiaxes(1)*semiaxes(2)*pi/2)/s.numcells;
            celldiam = sqrt(cellarea/pi)*2;
            approxperim = sum(semiaxes)*2;
            approxperimcells = approxperim/celldiam;
            theta = linspace( 0, 2*pi, approxperimcells*2 )';
            theta(end) = [];
            ct = cos(theta);
            st = sin(theta);
            userboundary = s.bbox;
            boundary = [ct,st].*semiaxes + centre;
        case 'semiellipse'
            if isempty( s.bbox ) || isempty( s.axis )
                return;
            end
            [centres,semiaxes,centre] = randInSemiEllipse( s.numcells, s.bbox, s.axis );
            switch s.axis
                case '+X'
                    thetamin = -pi/2;
                    thetamax = pi/2;
                case '-X'
                    thetamin = pi/2;
                    thetamax = pi*3/2;
                case '+Y'
                    thetamin = 0;
                    thetamax = pi;
                case '-Y'
                    thetamin = -pi;
                    thetamax = 0;
            end
            cellarea = (semiaxes(1)*semiaxes(2)*pi/2)/s.numcells;
            celldiam = sqrt(cellarea/pi)*2;
            approxperim = sum(semiaxes)*1.5;
            approxperimcells = approxperim/celldiam;
            theta = linspace( thetamin, thetamax, approxperimcells*2 )';
            ct = cos(theta);
            st = sin(theta);
            userboundary = s.bbox;
            boundary = [[ct,st].*semiaxes;[0,0]] + centre;
        case 'polygon'
            if isempty( s.vxs )
                return;
            end
            centres = randInPoly( s.numcells, s.vxs );
            userboundary = s.vxs;
            boundary = s.vxs;
        otherwise
            return;
    end
    
    
    

    % Use CVT to arrange them into a centroidal Voronoi tesselation.
    centres = centres';
    for i=1:s.numiters
        centres = ...
                cvt_iterate( ...
                    2, ...    % Dimensions.
                    s.numcells, ...      % Number of points? Why does it need this, when n is just size(pts,1)?
                    1000, ...   % Batch size.
                    3, ... % Sampling method code. 3 is 'USER'.
                    0, ... % Do not reset the random seed, to get a different result every time.
                    40, ... % 10000, ... % Sample points per generator.
                    0, ... % Random seed (if used).
                    centres, ... % The current centres.
                    1, ... % Between 0 and 1. Sets the allowed amount of change on each step.
                    s.mode, ... % 
                    userboundary, ...
                    s.axis ... % 
                );
    end
    centres = centres';
    
    
    % Construct the Voronoi cells.
    vmin = s.bbox([1 3]);
    vmax = s.bbox([2 4]);
    vcentre = (vmin + vmax)/2;
    semidiam = (vmax - vmin)/2;
    a = semidiam(1);
    b = semidiam(2);
    c = a+a+b;
    e = b*1.2;
    d = (e+c)*0.6;
    vprotect = [ (vcentre(1) + [0; d; -d]), (vcentre(2) + [-c; e; e]) ];
    [cellvxs,cells] = voronoin( [ centres; vprotect ] );
    % Remove the cells containing the protection points.
    cells = cells(1:(length(cells)-3));
    % Ensure that all polygons are listed in anticlockwise order.
    ac = isAnticlockwisePoly2D( cellvxs, cells );
    for i=find(~ac')
        xx = cells{i};
        cells{i} = xx( end:(-1):1 );
    end
    
    
    % Trim the Voronoi cells to the given rectangle.
    [cellvxs,cells] = truncateVoronoiToPolygon( s.bbox, cellvxs, cells, boundary, s.subdivideedge );
    if isempty(cellvxs)
        % Cannot complete layer.
        fprintf( 1, '**** Cannot construct Voronoi tessellation of cells.\n' );
        ok = false;
        return;
    end
    
    % Delete unused vertexes.
    [cells, cellvxs] = purgeUnusedVxs( cells, cellvxs );
end


function [vvxs,vcells] = truncateVoronoiToPolygon( bbox, vvxs, vcells, polyvxs, subdivideedge )
%[vvxs,vcells] = truncateVoronoiToEllipse( bbox, vvxs, vcells )
%   Modify the Voronoi tessellation representated by [vvxs,vcells] so that the
%   cells are confined to the ellipse. To do this the ellipse must be
%   approximated by a polygon, the number of sides of which needs to scale
%   with the number of cells.
%
%   We ignore all cells that include the point at infinity (since we cannot
%   determine the direction of any edge from a finite point to [Inf Inf]).
%   The point at infinity is assumed to be the first vertex in vvxs.

    if isempty( vvxs )
        return;
    end
    
    numEllipsePoints = size(polyvxs,1);
    polyedges = [ (1:numEllipsePoints)', [2:numEllipsePoints, 1]' ];
    
    % Determine which of the Voronoi mesh vertexes lie outside the polygon.
    vxin = inpolygon( vvxs(:,1), vvxs(:,2), ...
                      polyvxs(:,1), ...
                      polyvxs(:,2) );
    
    % A cell of the Voronoi diagram as returned by VORONOIN should never be
    % empty, but I have found that it can happen, so we have to remove
    % them.
    okcells = zeros( 1, length(vcells), 'logical' );
    for i=1:length(vcells)
        okcells(i) = (~isempty(vcells{i})) && all( vcells{i} ~= 1 );
    end
    vcells = { vcells{ okcells } };

    % Cells that intersect the boundary must be cut.
    cellsToAmendMap = zeros( 1, length(vcells) );
    for i=1:length(vcells)
        cellsToAmendMap(i) = any( vxin( vcells{i} ) ) && any( ~vxin( vcells{i} ) );
    end
    cellsToAmend = find( cellsToAmendMap );
                  
    lastin = zeros( 1, length(vcells) );
    cuttingEdges = zeros( length(vcells)*2, 2 );
    numcuttingedges = 0;
    
    % Rotate the vcells and find cutting edges.
    for i=1:length(vcells)
        testcvxs = vxin(vcells{i});
        if testcvxs(1)
            [mv,minstart] = min( testcvxs );
            if mv==1, continue; end
            [mv,minend] = min( testcvxs(length(testcvxs):-1:1) );
            minend = length(testcvxs) + 1 - minend;
            testcvxs = testcvxs( [ ((minend+1):end) ...
                                   (1:minend) ] );
            vcells{i} = vcells{i}( [ ((minend+1):end) ...
                                   (1:minend) ] );
            lastin(i) = length(testcvxs) - minend + minstart - 1;
        else
            [mv,maxstart] = max(testcvxs);
            if mv==0
                vcells{i} = [];
                continue;
            end
            [mv,maxend] = max( testcvxs(length(testcvxs):-1:1) );
            maxend = length(testcvxs) + 1 - maxend;
            testcvxs = testcvxs( [ (maxstart:end) ...
                                   (1:maxstart-1) ] );
            vcells{i} = vcells{i}( [ (maxstart:length(testcvxs)) ...
                                   (1:maxstart-1) ] );
            lastin(i) = maxend - maxstart + 1;
        end
        numcuttingedges = numcuttingedges+1;
        if i > length(lastin)
            fprintf( 1, '%d > length(lastin) = %d.\n', i, length(lastin) );
        elseif i > length(vcells)
            fprintf( 1, '%d > length(vcells) = %d.\n', i, length(vcells) );
        elseif (lastin(i)+1) > length(vcells{i})
            fprintf( 1, 'Error, length(vcells(%d)) = %d, lastin(%d)+1 = %d.\n', ...
                i, length(vcells(i)), i, lastin(i)+1 );
        end
        cuttingEdges(numcuttingedges,:) = [ vcells{i}(lastin(i)), vcells{i}(lastin(i)+1) ];
        numcuttingedges = numcuttingedges+1;
        cuttingEdges(numcuttingedges,:) = [ vcells{i}(length(testcvxs)), vcells{i}(1) ];
    end
    numcuttingcells = numcuttingedges/2;
    
    % Remove zeros and duplicates from cuttingEdges.
    cuttingEdges = sort( cuttingEdges(1:numcuttingedges,:), 2 );
    [uniqueCuttingEdges,toUniqueCE,fromUniqueCE] = unique( cuttingEdges, 'rows' );
    
    % Find the intersections of all the cutting edges with the polygon.
    intersections = zeros( size(uniqueCuttingEdges,1), 2 );
    polyedgecut = zeros( 1, size(uniqueCuttingEdges,1) );
    for i=1:size(uniqueCuttingEdges,1)
        vin = uniqueCuttingEdges(i,1);
        vout = uniqueCuttingEdges(i,2);
        cvx1 = vvxs(vin,:);
        cvx2 = vvxs(vout,:);
        cvx1 = cvx1';
        cvx2 = cvx2';
        for j=1:length(polyvxs)
            if j==1
                mvx1 = polyvxs(end,:)'; % mesh.nodes( polyvxs(length(polyvxs)), 1:2 )';
                mvx2 = polyvxs(1,:)'; % mesh.nodes( polyvxs(1), 1:2 )';
                [b,v] = lineIntersection( cvx1, ...
                                  cvx2, ...
                                  mvx1, ...
                                  mvx2 );
            else
                [b,v] = lineIntersection( cvx1, ...
                                  cvx2, ...
                                  polyvxs(j-1,:)', ... % mesh.nodes( polyvxs(j-1), 1:2 )', ...
                                  polyvxs(j,:)' ); % mesh.nodes( polyvxs(j), 1:2 )' );
            end
            if b
                intersections(i,:) = v;
                polyedgecut(i) = j;
                break;
            end
        end
    end
    
    % Append the intersections to the vertex list.
    numgivenvxs = size( vvxs, 1 );
    vvxs = [ vvxs; intersections ];
    
    % Append the polygon vertices to the vertex list.
    polystart = size( vvxs, 1 );
    vvxs = [ vvxs; polyvxs ];
%     if subdivideedge
%         vvxs = [ vvxs; polyvxs ];
%     end

    % Insert the intersection points into the cells.
    for i=1:numcuttingcells
        cutedge2 = i+i;
        cutedge1 = cutedge2-1;
        pe1 = polyedgecut( fromUniqueCE( cutedge1 ) );
        pe2 = polyedgecut( fromUniqueCE( cutedge2 ) );
        newvxs = [ numgivenvxs + fromUniqueCE( cutedge1 ), ...
                   numgivenvxs + fromUniqueCE( cutedge2 ) ];
        if (pe1 ~= pe2)
            % The two cutting edges cut different edges of the polygon.
            % We must include the intermediate polygon vertexes.
            if pe2 == pe1+1
                pv = pe1;
            elseif pe1 == pe2+1
                pv = pe2;
            else
              % pv = length(polyedges);
                pv = shortestSegmentBetween( length(polyedges), pe1, pe2 );
            end
            newvxs = [ newvxs(1), ...
                       polystart + pv, ...
                       newvxs(2) ];
        end
        vcells{cellsToAmend(i)} = ...
            [ vcells{cellsToAmend(i)}(1:lastin(cellsToAmend(i))), ...
              newvxs ];
        if 0
            figure(3);
            hold on;
            cvs = vcells{cellsToAmend(i)};
            cvs = [ cvs, cvs(1) ];
            plot( vvxs(cvs,1), vvxs(cvs,2), '-' );
          % pause;
            hold off;
        end
    end
end

function [cells, cellvxs] = purgeUnusedVxs( cells, cellvxs )
    [usedVxs,ia,ic] = unique( cell2mat(cells) );
    renumberVxs = zeros(1,max(usedVxs));
    renumberVxs(usedVxs) = (1:length(usedVxs));
    for i=1:length(cells)
        cells{i} = renumberVxs( cells{i} );
    end
    cellvxs = cellvxs(usedVxs,:);
end

