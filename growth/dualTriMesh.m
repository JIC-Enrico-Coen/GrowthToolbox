function celllayer = dualTriMesh( pts, trivxs, draw )
%   cells will have the following structure:
%
%                 cells: struct array
%                       vxs: vector of indexes to cell3dcoords
%                       edges: vector of indexes to edges
%          cell3dcoords: [Nx3 double]  xyz
%                 edges: [Kx4 integer] vi1, vi2, ci1, ci2

    [trivxss,triperms] = sort( trivxs, 2 );
    evenperms = 1+mod(triperms(:,1),3) == triperms(:,2);
    xx = [trivxss, (1:size(trivxss,1))' ];
    xx = [ reshape( xx( :, [1 2 4 2 3 4 1 3 4] )', 3, [] )', reshape([evenperms, evenperms, ~evenperms]',[],1) ];
    xx = sortrows( xx(:,[1 2 4 3]) );
    % xx is an array of all triples (A,B,C,D), where A and B are vertex
    % indexes, C is a triangle index, and D is a parity.  Equivalently, A and B are cell
    % indexes and C is a cell vertex index.  A and B are at opposite ends
    % of an edge of the triangle C.  So xx can also be considered as a list
    % of edge+triangle pairs.  The parity D indicates whether vertexes A
    % and B are listed in anticlockwise order relative to triangle C.
    %
    % Each edge on the border of the mesh appears once; every other edge
    % appears twice, in consecutive rows of xx.
    
    xxpair = all( xx(2:end,[1 2])==xx(1:(end-1),[1 2]), 2 );
    firstOfPair = [xxpair; false];
    secondOfPair = [false; xxpair];
    % firstOfPair and secondOfPair are boolean maps of the rows of xx.
    % For every edge appearing twice in xx, firstOfPair is true of the row
    % of its first occurrence and secondOfPair is true of its second
    % occurrence (which necessarily immediately follows the first.
    
    exterioredges = xx( ~(firstOfPair | secondOfPair), : );
    wrongway = exterioredges(:,3)==1;
    exterioredges(wrongway,[1 2]) = exterioredges(wrongway,[2,1]);
    exterioredges = [ exterioredges(:,[1 2 4]), zeros( size(exterioredges,1), 1 ) ];
    % exterioredges contains one row for every edge on the border of the
    % mesh.  Its four elements are the two vertexes at the ends of the edge
    % (listed in increasing order), the index of the triangle it belongs
    % to, and 0.  The rows are listed in the same order as the ordering of
    % the border vertexes of the mesh were in the pts array.

    interioredges = [ xx( firstOfPair, [1 2 4] ), xx( secondOfPair, 4 ) ];
    % interioredges contains one row for every edge in the interior of the
    % mesh.  Its four elements are the two vertexes at the ends of the edge
    % (listed in increasing order), and the indexes of the two triangles it
    % belongs (also listed in increasing order).
    
    % Both interioredges and exterioredges have a consistent relationship
    % between the four components of each row.  If listed in the order 1,
    % 3, 2, 4, the respective vertex, triangle, vertex and triangle (or
    % exterior space) are in clockwise order.
    
    tricentroids = permute( sum( reshape( pts( trivxss', :), 3, [], 3 ), 1 )/3, [3 2 1] )';
    % tricentroids is an array in which each row is the position of the
    % centroid of a triangle.  They are listed in the same order as trivxs.
    
    edgecentroids = permute( sum( reshape( pts( exterioredges(:,[1 2])', :), 2, [], 3 ), 1 )/2, [3 2 1] )';
    % edgecentroids is an array of the midpoints of all the border edges of
    % the mesh.  They are listed in the same order as the rows of
    % exterioredges.
    
    celllayer.cell3dcoords = [ tricentroids; edgecentroids ];
    % celllayer.cell3dcoords is an array of the 3D positions of all of the
    % vertexes of the dual mesh.
    
    edgecentroidoffset = size(tricentroids,1);
    % This is used to map indexes into edgecentroids to indexes into
    % celllayer.cell3dcoords.
    
    xx2 = exterioredges(:,[1 2]);
    [yy,p] = sort( xx2(:) );
    topend = p > size(exterioredges,1);
    zz = [ yy(2:2:end), p(topend) - size(exterioredges,1), p(~topend) ];
    % zz is an array of rows [A B C], where A is a vertex index and B and C
    % are indexes into exterioredges, specifying which two rows that vertex
    % occurs on.  zz has one row for every vertex on the mesh border, and
    % the rows are listed in ascending order of vertex index.
    
    dualborderedges = edgecentroidoffset + zz( :, [2 3] );
    % dualborderedges is a list of the endpoints of all the border edges of
    % the dual network, offset to correctly index into
    % celllayer.cell3dcoords.  The rows are listed in ascending order of
    % vertex index.

    extcellvertexindexes = edgecentroidoffset + (1:size(edgecentroids,1))';
    exterioredges(:,4) = extcellvertexindexes;
    
    dualedges = [ interioredges(:,[3 4 2 1]); exterioredges(:,[3 4 2 1]) ];
    % dualedges is a list of all of the edges of the dual network that
    % correspond to edges of the original mesh.  In each row [A B C D], the
    % elements [A B] are the two cell vertex indexes (mesh triangle
    % indexes) at either end, and [C D] are the two cells (mesh vertex
    % indexes) on either side.  The edges not included in this array are
    % those that join two border cell vertexes.
    celllayer.edges = [ dualedges; ...
                        [ edgecentroidoffset + zz( :, [2 3] ), zz(:,1), zeros(size(zz,1),1) ] ];
    % celllayer.edges lists, for every edge of the dual network, the cell
    % vertexes at each end and the cells on either side.
    % Like interioredges and exterioredges, celllayer.edges has the same
    % consistent relationship between the four components of each row.  If
    % listed in the order 1, 3, 2, 4, the respective cell vertex, cell,
    % cell vertex and cell (or exterior space) are in clockwise order.
    
    aa = sortrows( [ xx2(:), repmat( exterioredges(:,3), 2, 1 ), repmat( (1:size(exterioredges,1))', 2, 1 ) ] );
    bb = [ aa(1:2:end,1), reshape( aa(:,2), 2, [] )', reshape( aa(:,3), 2, [] )' ];
    % bb is an array of five-element rows [A B C D E], where A is a border
    % vertex, B and C are the border vertexes on either side of A, and D
    % and E are indexes into the corresponding rows of exterioredges.
    bbi = zeros( size(pts,1), 1 );
    bbi(bb(:,1)) = (1:size(bb,1))';
    % bbi translates indexes to the original vertexes into indexes to the
    % rows of the exterioredges array.
    
    
    
    e_vttei = sortrows( [ [celllayer.edges(:,[3 2 1]); celllayer.edges(:,[4 1 2])], repmat( (1:size(celllayer.edges,1))', 2, 1 ) ] );
    foo = find( e_vttei(2:end,1) ~= e_vttei(1:(end-1),1) );
    if e_vttei(1,1)==0
        starts = foo+1;
        ends = [foo(2:end);size(e_vttei,1)];
    else
        starts = [1;foo+1];
        ends = [foo;size(e_vttei,1)];
    end

    for v1=1:length(starts)
        nnbs = ends(v1) - starts(v1) + 1;
        cv1 = e_vttei( starts(v1):ends(v1), 2 );
        cv2 = e_vttei( starts(v1):ends(v1), 3 );
        v2 = e_vttei( starts(v1):ends(v1), 4 );
        [p1,i1] = sort(cv1);
        [p2,i2] = sort(cv2);
        i2(i2) = (1:length(i2))';
        
        % Sanity check
        sd = setdiff(cv1,cv2);
        if ~isempty(sd)
            warning('setdiff fails');
        end
        cvxs = zeros(1,nnbs);
        cedges = zeros(1,nnbs);
        k = 1;
        cvxs(1) = cv1(k);
        cedges(1) = v2(k);
        for j=2:nnbs
            k = i1(i2(k));
            cvxs(j) = cv1(k);
            cedges(j) = v2(k);
        end
        celllayer.cells(v1,1) = struct( 'vxs', cvxs, 'edges', cedges );
    end
    
    ok = validCellularLayer( celllayer );
    
%{
    triindexes = (1:size(trivxss,1))';
    vxcells = sortrows( [ trivxss(:), repmat(triindexes,size(trivxss,2),1) ] );
    % vxcells is an array of pairs [A B], where A is a vertex index and B
    % is the index of a triangle the vertex belongs to.  The elements are
    % listed in ascending order of A and then ascending order of B.
    foo = find( vxcells(2:end,1) ~= vxcells(1:(end-1),1) );
    starts = [1;foo+1];
    ends = [foo;size(vxcells,1)];
    for i=1:length(starts)
        nbs = vxcells( starts(i):ends(i), 2 );
        % nbs is a list of all the triangles that vertex i belongs to.
        nnbs = length(nbs);
        nbvxs = trivxs(nbs,:);
        % nbvxs lists all the vertexes of all the triangles that vertex i
        % belongs to.
        [p,q] = find( nbvxs==i );
        [p,pi] = sort(p);
        q = q(pi);
        q1 = mod(q,3)+1;
        q2 = mod(q1,3)+1;
        % For each triangle that vertex i belongs to, q lists the positions
        % it occurs in in each row of nbvxs.  q1 is the position after q
        % and q2 is the position after q1.
        v1 = zeros(nnbs,1);
        v2 = zeros(nnbs,1);
        for j=1:nnbs
            v1(j) = nbvxs(j,q1(j));
            v2(j) = nbvxs(j,q2(j));
        end
        % v1 lists the vertexes that are one place anticlockwise from
        % vertex i in each triangle.  v2 lists those that are two places
        % anticlockwise.
        [p1,i1] = sort(v1);
        [p2,i2] = sort(v2);
        i2(i2) = (1:length(i2))';
        sd = setdiff(v1,v2);
        bordercell = ~isempty(sd);
        if bordercell
            k = find( v1==sd(1), 1 );
            numsteps = nnbs-1;
        else
            k = 1;
            numsteps = nnbs-1;
        end
        cnbs = zeros(1,nnbs);
        cnbs(1) = nbs(k);
        for j=1:numsteps
            k = i1(i2(k));
            cnbs(j+1) = nbs(k);
        end
        if bordercell
            edgepts = bb( bbi(i),[2 3] );
            edgeindexes = edgecentroidoffset + bb( bbi(i),[4 5] );
            cedgepts = cnbs([1 end]);
            % edgepts and cedgepts should be the same pairs of integers,
            % possibly not in the same order.
            if edgepts(1)==cedgepts(1)
                cnbs = [ edgeindexes(1), cnbs, edgeindexes(2) ];
            else
                cnbs = [ edgeindexes(2), cnbs, edgeindexes(1) ];
            end
        end
        celllayer.cells(i) = struct( 'vxs', cnbs, 'edges', [] );
    end
%}  
    if draw
        figure(2);
        clf;
        axis equal
        plotedges( celllayer.cell3dcoords, celllayer.edges(:,[1 2]) );
        hold on
        cellcentroids = zeros( length(celllayer.cells), 3 );
        for i=1:length(celllayer.cells)
            vxis = celllayer.cells(i).vxs;
            vxs = celllayer.cell3dcoords(vxis,:);
            c = sum( vxs, 1 )/size( vxs, 1 );
            alpha = 0.1;  beta = 1-alpha;
            vxs = alpha*repmat( c, size(vxs,1), 1 ) + beta*vxs;
            plotpts( gca, vxs([1:end 1],:), '.-g' );
            cellcentroids(i,:) = c;
        end
        plotpts( gca, cellcentroids, 'ok' );
        hold off
    end
end

function plotedges( pts, edges )
    pe = reshape( pts( edges', : ), 2, [], 3 );
    holding = get( gca, 'NextPlot' );
    hold on;
    line( pe(:,:,1), pe(:,:,2), pe(:,:,3) );
    plotpts( gca, pts, 'or' );
    set( gca, 'NextPlot', holding );
end

function ok = validCellularLayer( celllayer )
% Check required fields are present.
    ok = false;
    requiredFields = { 'cell3dcoords', 'edges', 'cells' };
    if any( ~isfield( celllayer, requiredFields ) )
        fprintf( 1, 'Missing fields: {' );
        fprintf( 1, ' %s', requiredFields{:} );
        fprintf( 1, ' } expected, found {' );
        fns = fieldnames( celllayer );
        fprintf( 1, ' %s', fns{:} );
        fprintf( 1, ' }\n' );
        return;
    end
    requiredFields = { 'vxs', 'edges' };
    if any( ~isfield( celllayer.cells, requiredFields ) )
        fprintf( 1, 'Missing fields in cells struct: {' );
        fprintf( 1, ' %s', requiredFields{:} );
        fprintf( 1, ' } expected, found {' );
        fns = fieldnames( celllayer );
        fprintf( 1, ' %s', fns{:} );
        fprintf( 1, ' }\n' );
        return;
    end
    
    nvxs = size( celllayer.cell3dcoords, 1 );
    nedges = size( celllayer.edges, 1 );
    ncells = length( celllayer.cells );

% 1.  Every element of celllayer.edges(:,[1 2]) must be a valid index into celllayer.cell3dcoords.
    ok = arrayInRange( 'celllayer.edges(:,[1 2])', celllayer.edges(:,[1 2]), nvxs, false );
    if ~ok, return; end
        
% 
% 2.  Every element of celllayer.edges(:,[3 4]) must be a valid index into celllayer.cells,
% except that celllayer.edges(:,4) can include zeros.
    ok = arrayInRange( 'celllayer.edges(:,3)', celllayer.edges(:,3), ncells, false );
    if ~ok, return; end
    ok = arrayInRange( 'celllayer.edges(:,4)', celllayer.edges(:,4), ncells, true );
    if ~ok, return; end
% 
% 3.  Every member of every celllayer.cells(i).vxs must be a valid index into celllayer.cell3dcoords.
    ok = arrayInRange( 'celllayer.cells(:).vxs', [celllayer.cells(:).vxs], nvxs, false );
    if ~ok, return; end

% 4.  Every member of every celllayer.cells(i).edges must be a valid index into celllayer.edges.
    ok = arrayInRange( 'celllayer.cells(:).edges', [celllayer.cells(:).edges], nedges, false );
    if ~ok, return; end

% 5.  The endpoints of each edge as stored in celllayer.edges must agree with celllayer.cells(i).vxs.
    for i=1:ncells
        vxs = celllayer.cells(i).vxs;
        edges = celllayer.cells(i).edges;
        edgedata = celllayer.edges(edges,:);
        ncedges = length(edges);
        % i must occur exactly once in each row of edgedata(:,[3 4]).
        c1 = all( sum( edgedata(:,[3 4])==i, 2 )==1 );
        if ~c1
            fprintf( 1, 'Cell %d does not occur exactly once in each row of edgedata(:,[3 4])\.', i );
            edgedata(:,[3 4]);
            ok = false;
        end
        % Each row of edgedata(:,[1 2]) must occur consecutively in either order in vxs.
        for j=1:size(edgedata,1)
            j1 = find(edgedata(j,1)==vxs);
            j2 = find(edgedata(j,2)==vxs);
            if (j1 ~= mod(j2,ncedges)+1) && (j2 ~= mod(j1,ncedges)+1)
                fprintf( 1, 'Cell %d: Edgedata [%d %d] does not occur correctly in celllayer.cells.vxs.\n', ...
                    i, edgedata(j,[1 2]) );
                vxs
                edges
                edgedata
                ok = false;
            end
        end
    end
end

function ok = arrayInRange( msg, a, n, allowzero )
    minval = 1-allowzero;
    ok = all( (a(:) >= minval) & (a(:) <= n) );
    if ~ok
        fprintf( 1, '%s: max value found %d, max allowed %d.\n', ...
            msg, max(a(:)), n );
    end
end
