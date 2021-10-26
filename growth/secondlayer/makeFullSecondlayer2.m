function m = makeFullSecondlayer2( m, r )
%m = makeFullSecondlayer2( m, r )
%   Create a new second layer for a mesh.  R is the refinement, but is not
%   implemented.

% The second layer contains the following information:
% For each clone cell ci:
%       cells(ci).vxs(:)       A list of all its vertexes, in clockwise order.
%       cells(ci).edges(:)     A list of all its edges, in clockwise order.
%                              (Can be computed from the other data.)
%           These cannot be 2D arrays, since different cells may have
%           different numbers of vertexes or edges.
%       cellcolor(ci,1:3)	   Its colour.
%       cloneindex(ci)         Its clone index (an arbitrary integer).
% For each clone vertex vi:
%       vxFEMcell(vi)          Its FEM cell index.
%       vxBaryCoords(vi,1:3)   Its FEM cell barycentric coordinates.
%       cell3dcoords(vi,1:3)   Its 3D coordinates (which can be calculated
%                              from the other data).
% For each clone edge ei:
%       edges(ei,1:4)          The indexes of the clone vertexes at its ends
%           and the clone cells on either side (the second one is 0 if absent).
%           This can be computed from the other data.

    numFEMcells = size( m.tricellvxs, 1 );
    numFEMedges = size(m.edgecells,1);
    numFEMvxs = size( m.nodes, 1 );
    
    bioCellsPerFEM = r*(r-1)*3/2 + 1;
    bioVxsPerFEMCellSector = r*(r-1);
    bioVxsPerFEMCell = bioVxsPerFEMCellSector*3;
    bioVxsPerFEMEdge = r*2;
    bioVxsPerFEMCorners = 1;
    numbioVxs = bioVxsPerFEMCell + bioVxsPerFEMEdge + bioVxsPerFEMCorners;
    numbioCells = numFEMcells*bioCellsPerFEM + numFEMedges*(r-1) + numFEMvxs;
    nodecelledges = m.nodecelledges;
    
    m.secondlayer = deleteSecondLayerCells( m.secondlayer );
    
    m.secondlayer.cells = allocateCells( numbioCells );
    m.secondlayer.side = true( numbioCells, 1 );
    m.secondlayer.vxFEMcell = ones( numbioVxs, 1, 'int32' );
    m.secondlayer.vxBaryCoords = zeros( numbioVxs, 3, 'single' );
    
    % Create the interior vertexes for a generic FEM cell.
    interiorVxs = zeros( bioVxsPerFEMCell, 3 );
    curvx = 0;
    for i=1:r-1
        for j=1:i
            interiorVxs([curvx+1,curvx+2],:) = ...
                [ [r-i;r-i], ...
                  r+2*i-3*j+[2;1], ...
                  r-i+3*j-[2;1] ] / (3*r);
            curvx = curvx+2;
        end
    end
    interiorVxs = triplicate( interiorVxs, curvx );
    
    % Create the interior vertexes for a generic FEM edge.
    edgeVxs = zeros( bioVxsPerFEMEdge, 3 );
    curvx = 0;
    for j=1:r
        edgeVxs([curvx+1,curvx+2],:) = ...
            [ [0;0], ...
              3*r-3*j+[2;1], ...
              3*j-[2;1] ] / (3*r);
        curvx = curvx+2;
    end
    
    % Create the corner vertexes.
    % A corner is a FEM vertex which is an end of an edge that has a FEM
    % cell on only one side.
    cornerVxs = unique( m.edgeends( m.edgecells(:,2)==0, : ) );
    cornerEdges = zeros(1,length(cornerVxs));
    cornerCells = zeros(1,length(cornerVxs));
    for i=1:length(cornerVxs)
        e = find( m.edgeends==cornerVxs(i) );
        cornerEdges(i) = mod(e(1)-1,size(m.edgeends,1)) + 1;
        cornerCells(i) = m.edgecells(cornerEdges(i),1);
    end

    % For each cell, create the interior vertexes.
    numIntVxs = size(interiorVxs,1);
    for ci=1:numFEMcells
        range = (((ci-1)*numIntVxs)+1):(ci*numIntVxs);
        m.secondlayer.vxBaryCoords(range,:) = ...
            interiorVxs;
        m.secondlayer.vxFEMcell(range) = ci;
    end
    
    % For each edge, create the interior vertexes.
    numEdgeVxs = size(edgeVxs,1);
    for ei=1:numFEMedges
        ci = m.edgecells(ei,1);
        cv = edgeToCellVxs( m.tricellvxs(ci,:), m.edgeends(ei,:) );
        range = numIntVxs*numFEMcells ...
                    + ((((ei-1)*numEdgeVxs)+1):(ei*numEdgeVxs));
        m.secondlayer.vxBaryCoords(range,cv([3 1 2])) = edgeVxs;
        m.secondlayer.vxFEMcell(range) = ci;
    end

    % For each corner, create the vertex.
    vxsSoFar = length(m.secondlayer.vxFEMcell);
    for vi=1:length(cornerVxs)
        cv = edgeToCellVxs( m.tricellvxs(cornerCells(vi),:), ...
                            m.edgeends(cornerEdges(vi),:) );
        if cornerVxs(vi)==m.edgeends(cornerEdges(vi),1)
            m.secondlayer.vxBaryCoords(vxsSoFar+vi,cv) = [1 0 0];
        else
            m.secondlayer.vxBaryCoords(vxsSoFar+vi,cv) = [0 1 0];
        end
        m.secondlayer.vxFEMcell(vxsSoFar+vi) = cornerCells(vi);
    end

    % Create the cells.
    
    % Centre cell of each FEM cell
    if r==1
        for ci=1:numFEMcells
            eei = m.celledges( ci, : );
            edgebases = numFEMcells*bioVxsPerFEMCell + (eei-1)*bioVxsPerFEMEdge;
            ev = zeros(length(eei),2);
            for j=1:length(eei)
                if isupedge( m, ci, eei(j) )
                    ev(j,:) = edgebases(j) + int32([1 2]);
                else
                    ev(j,:) = edgebases(j) + int32([2 1]);
                end
            end
            m.secondlayer.cells(ci).vxs = reshape( ev', 1, [] );
        end
    else
        for ci=1:numFEMcells
            m.secondlayer.cells(ci).vxs = (ci-1)*numIntVxs + ...
                [ 1, 2, ...
                  bioVxsPerFEMCellSector+1, bioVxsPerFEMCellSector+2, ...
                  bioVxsPerFEMCellSector*2+1, bioVxsPerFEMCellSector*2+2 ];
          % m.secondlayer.cells(ci).vxs
        end
    end
    
    % Other interior cells of each FEM cell.
    numcells = numFEMcells;
    if r > 1
        for ci=1:numFEMcells
            % Cells entirely within a sector.
            for i=1:r-3
                for j=1:i
                    basevx = i*(i-1) - 1 + 2*j;
                    vxs = [ 0, ...
                            1, ...
                            2*i + 2, ...
                            4*i + 5, ...
                            4*i + 4, ...
                            2*i + 1 ];
                    for k=0:2
                        m.secondlayer.cells(numcells+1).vxs = (ci-1)*numIntVxs + ...
                            basevx + vxs + k*bioVxsPerFEMCellSector;
                      % m.secondlayer.cells(numcells+1).vxs
                        numcells = numcells+1;
                    end
                end
            end
            % Cells joining sectors.
            for i=1:r-2
                basevx1 = i*(i-1) + 1;
                basevx2 = i*(i+1);
                vxs1 = [ basevx1, ...
                         basevx1 + 2*i + 1, ...
                         basevx1 + 2*i ];
                vxs2 = [ basevx2 + 2*i + 2, ...
                         basevx2 + 2*i + 1, ...
                         basevx2 ];
                for k=0:2
                    m.secondlayer.cells(numcells+1).vxs = (ci-1)*numIntVxs + ...
                        [ vxs1 + k*bioVxsPerFEMCellSector, ...
                          vxs2 + pred3(k)*bioVxsPerFEMCellSector];
                  % m.secondlayer.cells(numcells+1).vxs
                    numcells = numcells+1;
                end
            end
        end
    end
    
    % Cells within a FEM cell but adjoining a FEM edge.
    if r > 1
        for ei=1:numFEMedges
            edgebase = numFEMcells*bioVxsPerFEMCell + (ei-1) * bioVxsPerFEMEdge;
            for eei=1:2
                ci = m.edgecells(ei,eei);
                if ci ~= 0
                    cvi = edgeToCellVxs( m.tricellvxs(ci,:), m.edgeends(ei,:) );
                    cei = find( m.celledges(ci,:)==ei );
                  % cei==cvi(3)
                    up = cvi(2) == mod( cvi(1), 3 ) + 1;
                    cellbase = (ci-1)*bioVxsPerFEMCell ...
                               + (r-2)*(r-1) + 1 ...
                               + (cei-1)*bioVxsPerFEMCellSector;
                    for i=1:r-2
                        if up
                            ev1 = edgebase + 2*i + 1;
                            ev2 = ev1 + 1;
                        else
                            ev1 = edgebase + 2*(r-i) - 1;
                            ev2 = ev1 + 1;
                        end
                        cv1 = cellbase + 2*i - 1;
                        cv4 = cv1 + 1;
                        cv2 = cv1 - 2*r + 3;
                        cv3 = cv2 + 1;
                        if up
                            m.secondlayer.cells(numcells+1).vxs = [ ...
                                ev1, ...
                                ev2, ...
                                cv4, ...
                                cv3, ...
                                cv2, ...
                                cv1 ];
                        else
                            m.secondlayer.cells(numcells+1).vxs = [ ...
                                ev1, ...
                                ev2, ...
                                cv1, ...
                                cv2, ...
                                cv3, ...
                                cv4 ];
                        end
                      % scvxs = m.secondlayer.cells(numcells+1).vxs
                        numcells = numcells+1;
                    end
                end
            end
        end
    end
    
    % Cells within a FEM cell in the corners
    if r > 1
        for ci=1:numFEMcells
            for k=1:3
                eii = m.celledges(ci,[1 2 3]~=k);
                if k==2, eii = eii([2 1]); end
                ev1 = m.edgeends(eii(1),:);
                ev2 = m.edgeends(eii(2),:);
                edgebase1 = numFEMcells*bioVxsPerFEMCell + (eii(1)-1)*bioVxsPerFEMEdge;
                edgebase2 = numFEMcells*bioVxsPerFEMCell + (eii(2)-1)*bioVxsPerFEMEdge;
                vi = m.tricellvxs(ci,k);
                up1 = vi==ev1(1);
                if up1
                    ev11 = edgebase1 + 1;
                    ev12 = edgebase1 + 2;
                else
                    ev11 = edgebase1 + 2*r;
                    ev12 = ev11 - 1;
                end
                up2 = vi==ev2(1);
                if up2
                    ev21 = edgebase2 + 1;
                    ev22 = edgebase2 + 2;
                else
                    ev21 = edgebase2 + 2*r;
                    ev22 = ev21 - 1;
                end
                cellbase = (ci-1)*bioVxsPerFEMCell;
                cv1 = cellbase + (r-1)*(r-2) + 1 + pred3(k-1)*bioVxsPerFEMCellSector;
                cv2 = cellbase + r*(r-1) + succ3(k-1)*bioVxsPerFEMCellSector;
                m.secondlayer.cells(numcells+1).vxs = [ cv1, cv2, ev12, ev11, ev21, ev22 ];
              % scvxs = m.secondlayer.cells(numcells+1).vxs
                numcells = numcells+1;
            end
        end
    end
    
    % Edge cells for non-border edges.
    if r > 1
        for ei=1:numFEMedges
            c2 = m.edgecells(ei,2);
            if c2 ~= 0
                c1 = m.edgecells(ei,1);
                cv1 = edgeToCellVxs( m.tricellvxs(c1,:), m.edgeends(ei,:) );
                cv2 = edgeToCellVxs( m.tricellvxs(c2,:), m.edgeends(ei,:) );
                cei1 = cv1(3);
                cei2 = cv2(3);
                up1 = isupedge( m, c1, ei );
                up2 = isupedge( m, c2, ei );
                edgebase = numFEMcells*bioVxsPerFEMCell + (ei-1)*bioVxsPerFEMEdge;
                cellbase1 = (c1-1)*bioVxsPerFEMCell + (cei1-1)*bioVxsPerFEMCellSector ...
                    + (r-1)*(r-2);
                cellbase2 = (c2-1)*bioVxsPerFEMCell + (cei2-1)*bioVxsPerFEMCellSector ...
                    + (r-1)*(r-2);
                for i=1:r-1
                    e1 = edgebase + 2*i;
                    e2 = e1 + 1;
                    if up1
                        c11 = cellbase1 + 2*i - 1;
                        c12 = c11 + 1;
                    else
                        c11 = cellbase1 + 2*(r-i);
                        c12 = c11 - 1;
                    end
                    if up2
                        c21 = cellbase2 + 2*i - 1;
                        c22 = c21 + 1;
                    else
                        c21 = cellbase2 + 2*(r-i);
                        c22 = c21 - 1;
                    end
                    m.secondlayer.cells(numcells+1).vxs = ...
                        [ e1, c21, c22, e2, c12, c11 ];
                    numcells = numcells+1;
                end
            end
        end
    end
    
    % Edge cells for border edges.
    if r > 1
        for ei=1:numFEMedges
            if m.edgecells(ei,2) == 0
                edgebase = numFEMcells*bioVxsPerFEMCell + (ei-1) * bioVxsPerFEMEdge;
                ci = m.edgecells(ei,1);
                cei = find( m.celledges(ci,:)==ei );
                cellbase = (ci-1)*bioVxsPerFEMCell ...
                           + (r-2)*(r-1) + 1 ...
                           + (cei-1)*bioVxsPerFEMCellSector;
                for i=1:r-1
                    ev1 = edgebase + 2*i;
                    ev2 = ev1+1;
                    up = isupedge( m, ci, ei );
                    if up
                        cv1 = cellbase + 2*i - 2;
                        cv2 = cv1 + 1;
                    else
                        cv1 = cellbase + 2*(r-i) - 1;
                        cv2 = cv1 - 1;
                    end
                    m.secondlayer.cells(numcells+1).vxs = [ ev1, ev2, cv2, cv1 ];
                    numcells = numcells+1;
                end
            end
        end
    end
    
    % Vertex cells for non-corner vertexes.
    if 1
        noncorners = 1:size(m.nodes,1);
        noncorners(cornerVxs) = 0;
        noncorners = find( noncorners );
        for cvi = 1:length(noncorners)
            cv = noncorners(cvi);
            nce = nodecelledges{cv};
            p = nce(1,:);  % The edges incident on v, ordered in the positive sense.
            ne = length(p);
            cellvxs = zeros(1,ne);
            for i=1:ne
                ei = p(i);
                first = m.edgeends(ei,1)==cv;
                if first
                    cellvxs(i) = numFEMcells*bioVxsPerFEMCell + (ei-1)*bioVxsPerFEMEdge + 1;
                else
                    cellvxs(i) = numFEMcells*bioVxsPerFEMCell + ei*bioVxsPerFEMEdge;
                end
            end
            m.secondlayer.cells(numcells+1).vxs = cellvxs;
            numcells = numcells+1;
        end
    end
    
    % Vertex cells for corner vertexes.
    if 1
        for cvi = 1:length(cornerVxs)
            cv = cornerVxs(cvi);
            % Find all the edges and cells incident on the vertex.
            % Arrange them in order.
%             vertexEdges = find( (m.edgeends(:,1)==cv) | (m.edgeends(:,2)==cv) );
%             p = decodePermutation( [ m.edgecells(vertexEdges,:), vertexEdges ] );
%             ne = size(p,1);
            nce = m.nodecelledges{cv};
            p = nce(1,:);  % The edges incident on v, ordered in the positive sense.
            ne = length(p);
            cellvxs = zeros(1,ne+1);
            for i=1:ne
                ei = p(i);
                first = m.edgeends(ei,1)==cv;
                if first
                    cellvxs(i) = numFEMcells*bioVxsPerFEMCell + (ei-1)*bioVxsPerFEMEdge + 1;
                else
                    cellvxs(i) = numFEMcells*bioVxsPerFEMCell + ei*bioVxsPerFEMEdge;
                end
            end
            cellvxs(ne+1) = numFEMcells*bioVxsPerFEMCell ...
                                   + numFEMedges*bioVxsPerFEMEdge ...
                                   + cvi;
          % cellvxs
            m.secondlayer.cells(numcells+1).vxs = cellvxs;
            numcells = numcells+1;
        end
    end

    RANDSCALE = 1/(r*7);
    m.secondlayer.vxBaryCoords = randomiseBaryCoords( m.secondlayer.vxBaryCoords, RANDSCALE );

    % Calculate the global coordinates of the vertexes.
    m.secondlayer.cell3dcoords = zeros( length(m.secondlayer.vxFEMcell), 3 );
    femVxs = m.tricellvxs( m.secondlayer.vxFEMcell, : );
    for vi=1:length(m.secondlayer.vxFEMcell)
        m.secondlayer.cell3dcoords( vi, : ) = ...
        	m.secondlayer.vxBaryCoords(vi,:) * m.nodes( femVxs(vi,:), : );
    end
    m.secondlayer.cloneindex = ...
                ones( length( m.secondlayer.cells ), 1 );
    m.secondlayer.cellcolor = ...
        secondlayercolor( length( m.secondlayer.cells ), m.globalProps.colorparams(1,:) );
end

function p = pred3( k )
    p = mod(k+2,3);
end

function p = succ3( k )
    p = mod(k+1,3);
end

function u = isupedge( m, ci, ei )
    cei = find( m.celledges(ci,:)==ei );
    v = mod(cei,3)+1;
    u = m.edgeends(ei,1)==m.tricellvxs(ci,v);
end

function v = edgeToCellVxs( tricellvxs, edgeends )
    v1 = find( edgeends(1)==tricellvxs );
    v2 = find( edgeends(2)==tricellvxs );
    v = [v1,v2,third(v1,v2)];
end

function v3 = third( v1, v2 )
    x = [1 1 1];
    x([v1 v2]) = 0;
    v3 = find(x);
end

function a = randomiseBaryCoords( a, s )
    zs = a==0;
    a = a + rand(size(a))*s;
    a(zs) = 0;
    a = normaliseBaryCoords( a );
end

function a = triplicate( a, n )
    a(n+1:2*n,:) = a(1:n,[3,1,2]);
    a(2*n+1:3*n,:) = a(1:n,[2,3,1]);
end

