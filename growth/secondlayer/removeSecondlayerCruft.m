function m = removeSecondlayerCruft( m, edgeminlength )
%m = removeSecondlayerCruft( m )
%   Remove from the bio layer:
%       All cells with fewer than 3 vertexes.
%       All edges shorter than a threshold value.
%       All edges and vertexes not part of any cell.

    numvxs = length(m.secondlayer.vxFEMcell);
    numedges = size( m.secondlayer.edges, 1 );
    numcells = length(m.secondlayer.cells);
    vertexesToDelete = false( numvxs, 1 );
    edgesToDelete = false( numedges, 1 );
    cellsToDelete = false( numcells, 1 );
    cellsPerVertex = zeros(numvxs,1);
    cellsPerEdge = zeros(numedges,1);
    
    % Count how many cells each vertex and edge belongs to.
    for i=1:numcells
        cev = m.secondlayer.cells(i);
        cellsPerVertex(cev.vxs) = cellsPerVertex(cev.vxs)+1;
        cellsPerEdge(cev.edges) = cellsPerEdge(cev.edges)+1;
    end
    
    if any(cellsPerVertex==0)
        fprintf( 1, '%s: unreferenced vxs:', mfilename() );
        fprintf( 1, ' %d', find(cellsPerVertex==0) );
        fprintf( 1,'\n' );
    end
    if any(cellsPerEdge==0)
        fprintf( 1, '%s: unreferenced edges:', mfilename() );
        fprintf( 1, ' %d', find(cellsPerEdge==0) );
        fprintf( 1,'\n' );
    end
    
    % Find the edges that are to be elided.
    edgevectors = m.secondlayer.cell3dcoords( m.secondlayer.edges(:,1), : ) ...
                  - m.secondlayer.cell3dcoords( m.secondlayer.edges(:,2), : );
    edgelengthssq = sum( edgevectors.^2, 2 );
    edgesToElide = edgelengthssq <= edgeminlength^2;
    edgesToDelete( edgesToElide ) = true;
    
    if any(edgesToElide==0)
        fprintf( 1, '%s: elided edges:', mfilename() );
        fprintf( 1, ' %d', find(edgesToElide) );
        fprintf( 1,'\n' );
    end
    
    % Find all cells with fewer than 3 edges, taking into account the edges
    % to be deleted.  Decrement the counts for their edges and vertexes.
    for i=1:numcells
        cedges = m.secondlayer.cells(i).edges;
        remainingedges = sum( ~edgesToDelete(cedges) );
        if remainingedges<3
            if ~cellsToDelete(i)
                cellsToDelete(i) = true;
                cellsPerEdge(cedges) = cellsPerEdge(cedges)-1;
                cvxs = m.secondlayer.cells(i).vxs;
                cellsPerVertex(cvxs) = cellsPerVertex(cvxs)-1;
            end
        end
    end
    
    if any(cellsPerVertex==0)
        fprintf( 1, '%s: after deleting small cells, unreferenced vxs:', mfilename() );
        fprintf( 1, ' %d', find(cellsPerVertex==0) );
        fprintf( 1,'\n' );
    end
    if any(cellsPerEdge==0)
        fprintf( 1, '%s: after deleting small cells, unreferenced edges:', mfilename() );
        fprintf( 1, ' %d', find(cellsPerEdge==0) );
        fprintf( 1,'\n' );
    end
    
    % Vertexes and edges not belonging to any cell should be deleted.
    edgesToDelete( cellsPerEdge <= 0 ) = true;
    vertexesToDelete( cellsPerVertex <= 0 ) = true;
    
    % Remove cells to be deleted from mention in secondlayer.edges.
    ec = m.secondlayer.edges(:,[3 4]);
    ec1 = ec(ec>0);
    ec1(cellsToDelete(ec1)) = 0;
    ec(ec>0) = ec1;
    m.secondlayer.edges(:,[3 4]) = ec;
    
    % Flip edges that have empty space as their first cell.
    flips = m.secondlayer.edges(:,3) <= 0;
    m.secondlayer.edges(flips,:) = m.secondlayer.edges(flips,[2 1 4 3]);
    
    % If an edge marked for elision does not belong to any remaining cell,
    % don't bother eliding it.
    edgesToElide( m.secondlayer.edges(:,3) <= 0 ) = false;
    
    % Do the edge and vertex elision.
    vertexReplacements = (1:numvxs)';
    for ei=find(edgesToElide')
        edata = m.secondlayer.edges( ei, : );
        v1 = edata(1);
        v2 = edata(2);
        c1 = edata(3);
        c2 = edata(4);
        % Elide ei and v1 from m.secondlayer.cells(c1) and
        % m.secondlayer.cells(c2).
        cev = m.secondlayer.cells(c1);
        cei = find( cev.edges==ei );
        if numel(cei) ~= 1
            xxxx = 1;
        end
        if cev.vxs(cei) ~= v1
            xxxx = 1;
        end
        assert( cev.vxs(cei)==v1 )
        cev.edges(cei) = [];
        cev.vxs(cei) = [];
        m.secondlayer.cells(c1) = cev;
        
        if c2 > 0
            cev = m.secondlayer.cells(c2);
            cei = find( cev.edges==ei );
            cei1 = indexAdd( cei, 1, length( cev.edges ) );
            assert( cev.vxs(cei1)==v1 )
            cev.edges(cei) = [];
            cev.vxs(cei1) = [];
            if cei1==1
                cev.vxs = cev.vxs( [end (1:(end-1))] );
            end
            m.secondlayer.cells(c2) = cev;
        end
        
        v0 = v2;
        while vertexReplacements(v0) ~= v0
            v0 = vertexReplacements(v0);
        end
        vertexReplacements(v1) = v0;
        vertexesToDelete(v1) = true;
        
    end
    % Remove neighbour data from elided edges.
    m.secondlayer.edges( edgesToElide, [3 4] ) = 0;
    
    m.secondlayer.edges(:,[1 2]) = vertexReplacements( m.secondlayer.edges(:,[1 2]) );
    for ci=1:numcells
        cev = m.secondlayer.cells(ci);
        cev.vxs = vertexReplacements(cev.vxs);
        m.secondlayer.cells(ci) = cev;
    end
   
    % Now renumber all edges, vertexes, and cells.
    fprintf( 1, '%s: deleting %d cells.\n', mfilename(), sum(cellsToDelete) );
    m.secondlayer = deleteSecondLayerCells( m.secondlayer, cellsToDelete, m.globalDynamicProps.currenttime );
end
