function [cells,cellvxs,centres] = makeVoronoiRectangle( numcells, numiters, bbox, subdivideedge, fixedCentres )
%[cells,cellvxs,centres] = makeVoronoiRectangle( numcells, numiters, bbox, subdivideedge, fixedCentres )
%   Make a centroidal Voronoi tessellation of the given rectangle, with n
%   cells. bbox gives the rectangle as [xlo, xhi, ylo, yhi].
%
%   The SUBDIVIDEEDGE argument is never used.
%
%   FIXEDCENTRES is a K*2 array of points which are required to be included
%   as cell centres. If absent it is taken to be empty. Their number is
%   included in the number of cells.

    if (nargin < 5) || isempty( fixedCentres )
        fixedCentres = zeros(0, 2);
    end
    fixedCentres = fixedCentres'; % For compatibility with cvt_iterate.
    numfixedcentres = size( fixedCentres, 2 );
    nummovingcentres = max( 0, numcells-size(fixedCentres,2) );
    numcells = numfixedcentres + nummovingcentres;

    % Choose the initial centres uniformly at random.
    centres = [ fixedCentres, randInRectangle( nummovingcentres, bbox )' ];

    if nummovingcentres > 0
        % Use CVT to arrange them into a centroidal Voronoi tessellation.
        for i=1:numiters
            centres = ...
                    cvt_iterate( ...
                        2, ...    % Dimensions.
                        numcells, ...      % Number of points? Why does it need this, when numcells is just size(pts,1)?
                        1000, ...   % Batch size.
                        3, ... % Sampling method code. 3 is 'USER'.
                        0, ... % Do not reset the random seed, to get a different result every time.
                        40, ... % 10000, ... % Sample points per generator.
                        0, ... % Random seed (if used).
                        centres, ... % The current centres.
                        1, ... % Between 0 and 1. Sets the allowed amount of change on each step.
                        'usertype', 'rectangle', ...
                        'bbox', bbox ...
                    );
            if ~isempty(fixedCentres)
                centres = [ fixedCentres, centres(:,(numfixedcentres+1):end) ];
            end
        end
        centres = centres';
    end
    
    
    % Add protection points.
    vmin = bbox([1 3]);  % min( pts(:,1:2) );
    vmax = bbox([2 4]);  % max( pts(:,1:2) );
    vcentre = (vmin + vmax)/2;
    semidiam = (vmax - vmin)/2;
    a = semidiam(1);
    b = semidiam(2);
    c = a+a+b;
    e = b*1.2;
    d = (e+c)*0.6;
    vprotect = [ (vcentre(1) + [0; d; -d]), (vcentre(2) + [-c; e; e]) ];
    
    % Construct the Voronoi cells.
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
    [cellvxs,cells] = truncateVoronoiToRectangle( bbox, cellvxs, cells, subdivideedge );
    if isempty(cellvxs)
        % Cannot complete layer.
        fprintf( 1, '**** Cannot construct Voronoi tessellation of cells.\n' );
        ok = false;
        return;
    end
    
    % Delete unused vertexes.
    [cells, cellvxs] = purgeUnusedVxs( cells, cellvxs );
end


function [vvxs,vcells] = truncateVoronoiToRectangle( bbox, vvxs, vcells, subdivideedge )
%[vvxs,vcells] = truncateVoronoiToRectangle( bbox, vvxs, vcells )
%   Modify the Voronoi tessellation representated by [vvxs,vcells] so that the
%   cells are confined to the bounding box.
%   We ignore all cells that include the point at infinity (since we cannot
%   determine the direction of any edge from a finite point to [Inf Inf]).
%   The point at infinity is assumed to be the first vertex in vvxs.

    if isempty( vvxs )
        return;
    end
    
    % Find the FEM edges bounding the Voronoi region.
    polyvxs = bbox( [1 3;2 3;2 4;1 4] );
    polyedges = [1 2;2 3;3 4;4 1];
    
    % Determine which of the Voronoi mesh vertexes lie outside the polygon.
    vxin = inpolygon( vvxs(:,1), vvxs(:,2), ...
                      polyvxs(:,1), ...
                      polyvxs(:,2) );
    
    % A cell of the Voronoi diagram as returned by VORONOIN should never be
    % empty, but I have found that it can happen, so we have to remove
    % them. We also remove all cells contianing the point at infinity.
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

    % Insert the intersection points into the cells.
    for i=1:numcuttingcells
        cutedge2 = i+i;
        cutedge1 = cutedge2-1;
        pe1 = polyedgecut( fromUniqueCE( cutedge1 ) );
        pe2 = polyedgecut( fromUniqueCE( cutedge2 ) );
        if pe1==pe2
            % The two cutting edges cut the same edge of the polygon.
            newvxs = [ numgivenvxs + fromUniqueCE( cutedge1 ), ...
                       numgivenvxs + fromUniqueCE( cutedge2 ) ];
        else
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
            newvxs = [ numgivenvxs + fromUniqueCE( cutedge1 ), ...
                       polystart + pv, ...
                       numgivenvxs + fromUniqueCE( cutedge2 ) ];
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
