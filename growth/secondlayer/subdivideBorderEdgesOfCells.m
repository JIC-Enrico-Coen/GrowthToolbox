function m = subdivideBorderEdgesOfCells( m, targetLength )
    borderedges = m.secondlayer.edges(:,4)==0;
    borderedgevecs = m.secondlayer.cell3dcoords( m.secondlayer.edges( borderedges, 1 ), : ) ...
                     - m.secondlayer.cell3dcoords( m.secondlayer.edges( borderedges, 2 ), : );
    borderedgelengths = sqrt( sum( borderedgevecs.^2, 2 ) );
    borderedgelist = find( borderedges );
    numsegs = round( borderedgelengths/targetLength );
    edgestosplit = borderedgelist( numsegs > 1 );
    numsegs = numsegs( numsegs > 1 );
    numtosplit = length( edgestosplit );
    
    
    numoldvxs = getNumberOfCellvertexes( m );
    numoldedges = size( m.secondlayer.edges, 1 );
    numnewvxs = sum(numsegs) - length(numsegs);
    fprintf( 1, '%s: %d edges to split, %d new vertexes.\n', mfilename(), numtosplit, numnewvxs );

    if isempty(edgestosplit)
        return;
    end
        
        
        
    newvxs = zeros(numnewvxs,3);
    hints = zeros(numnewvxs,2,'int32');
    updatedEdges = zeros( numtosplit, 2, 'int32' );
    newInteriorBorder = zeros( numnewvxs, 1, 'logical' );
    newEdgeGeneration = zeros( numnewvxs, 1, 'int32' );
    newEdgepropertyindex = zeros( numnewvxs, 1, 'int32' );
        
    newvxsi = 0;
    
    for i=1:numtosplit
        ei = edgestosplit(i);
        ci = m.secondlayer.edges(ei,3);
        v1 = m.secondlayer.edges(ei,1);
        v2 = m.secondlayer.edges(ei,2);
        cve = m.secondlayer.cells(ci);
        cvxs = cve.vxs;
        ces = cve.edges;
        cv1 = find( cvxs==v1, 1 );
        cv2 = find( cvxs==v2, 1 );
        if cv1 == 1 + mod( cv2, length(cv2) )
            x = cv2;
            cv2 = cv1;
            cv1 = x;
            x = v2;
            v2 = v1;
            v1 = x;
        end
        
        ratios = linspace( 0, 1, numsegs(i)+1 )';
        ratios([1 end]) = [];
        newvxs1 = (1-ratios)*m.secondlayer.cell3dcoords(v1,:) + ratios*m.secondlayer.cell3dcoords(v2,:);
        numvxs1 = size(newvxs1,1);
        newvxs( (newvxsi+1):(newvxsi+numvxs1), : ) = newvxs1;
        
        newvxindexes = (numoldvxs+newvxsi+1):(numoldvxs+newvxsi+numvxs1);
        newedgeindexes = (numoldedges+newvxsi+1):(numoldedges+newvxsi+numvxs1);
        ei1 = ces(cv1);
        % Check that ei1 is the same edge as ei.
        if ei1 ~= ei
            fprintf( 1, '%s: inconsistency found: edge %d expected, %d found.\n', mfilename(), ei1, ei );
            xxxx = 1;
        end
        newedges1 = [ newvxindexes', [newvxindexes(2:end)'; v2], ci+zeros(numvxs1,1,'int32'), zeros(numvxs1,1,'int32') ];
        newvxsindexrange = (newvxsi+1):(newvxsi+numvxs1);
        newedges( newvxsindexrange, : ) = newedges1;
        updatedEdges(i,:) = [v1 newvxindexes(1)];
        newInteriorBorder(newvxsindexrange) = m.secondlayer.interiorborder( ei1 );
        newEdgeGeneration(newvxsindexrange) = m.secondlayer.generation( ei1 );
        newEdgepropertyindex(newvxsindexrange) = m.secondlayer.edgepropertyindex( ei1 );
        hints(newvxsindexrange,:) = repmat( m.secondlayer.vxFEMcell([v1 v2])', numvxs1, 1 );
        
        cve.vxs = [ cvxs(1:cv1), newvxindexes, cvxs((cv1+1):end) ];
        cve.edges = [ ces(1:cv1), newedgeindexes, ces((cv1+1):end) ];
        
        
        m.secondlayer.cells(ci) = cve;
        newvxsi = newvxsi + numvxs1;
    end
    
%   peredgefields: {'edges'  'interiorborder'  'generation'  'edgepropertyindex'}
    newvxFEMcell = zeros( numnewvxs, 1 );
    newvxBaryCoords = zeros( numnewvxs, getNumVxsPerFE(m) );
    bcerr = zeros( numnewvxs, 1 );
    abserr = zeros( numnewvxs, 1 );
    for i=1:numnewvxs
        [ newvxFEMcell(i), newvxBaryCoords(i,:), bcerr(i), abserr(i) ] = findFE( m, newvxs(i,:), 'hint', hints(i,:) );
    end
    
    m.secondlayer.edges(edgestosplit,[1 2]) = updatedEdges;
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; newvxFEMcell ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; newvxBaryCoords ];
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; newvxs ];
    m.secondlayer.edges = [ m.secondlayer.edges; newedges ];
    m.secondlayer.interiorborder = [ m.secondlayer.interiorborder; newInteriorBorder ];
    m.secondlayer.generation = [ m.secondlayer.generation; newEdgeGeneration ];
    m.secondlayer.edgepropertyindex = [ m.secondlayer.edgepropertyindex; newEdgepropertyindex ];
end
