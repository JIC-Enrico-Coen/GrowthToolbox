function [vvxs,vcells] = truncateCells( mesh, vvxs, vcells, region, regionmap )
%[vvxs,vcells] = truncateCells( mesh, vvxs, vcells, region, regionmap )
%   Modify the Voronoi tessellation representated by [vvxs,vcells] so that the
%   cells are confined to the FEM elements containing the Voronoi generators.
%   We ignore all cells that include the point at infinity (since we cannot
%   determine the direction of any edge from a finite point to [Inf Inf]).
%   The point at infinity is assumed to be the first vertex in vvxs.

    if isempty( vvxs )
        return;
    end
    
    % Find the FEM edges bounding the Voronoi region.
    [polyvxs,polyedges] = makePolygon( mesh, region, regionmap );
    if isempty(polyvxs)
        vvxs = zeros(0,2);
        vcells = {};
        return;
    end
    
    % Determine which of the Voronoi mesh vertexes lie outside the polygon.
    vxin = inpolygon( vvxs(:,1), vvxs(:,2), ...
                      mesh.nodes( polyvxs, 1 ), ...
                      mesh.nodes( polyvxs, 2 ) );
    
    okcells = zeros( 1, length(vcells) );
    for i=1:length(vcells)
        okcells(i) = (~isempty(vcells{i})) && all( vcells{i} ~= 1 );
        % A cell of the Voronoi diagram as returned by VORONOIN should never
        % be empty, but I have found that it can happen.
    end
    vcells = { vcells{ logical(okcells) } };

    if 0
        for i=find(okcells)
            if ~any( vxin( vcells{i} ) )
                fprintf( 1, 'Warning: cell %d has no intersections with the Voronoi region.\n', i );
                okcells(i) = 1==0;
            end
        end
        vcells = { vcells{ logical(okcells) } };
    end

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
                mvx1 = mesh.nodes( polyvxs(length(polyvxs)), 1:2 )';
                mvx2 = mesh.nodes( polyvxs(1), 1:2 )';
                [b,v] = lineIntersection( cvx1, ...
                                  cvx2, ...
                                  mvx1, ...
                                  mvx2 );
            else
                [b,v] = lineIntersection( cvx1, ...
                                  cvx2, ...
                                  mesh.nodes( polyvxs(j-1), 1:2 )', ...
                                  mesh.nodes( polyvxs(j), 1:2 )' );
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
    vvxs = [ vvxs; mesh.nodes( polyvxs, 1:2 ) ];

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
