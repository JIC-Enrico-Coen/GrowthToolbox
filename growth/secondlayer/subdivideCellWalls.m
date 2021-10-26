function m = subdivideCellWalls( m, dist, displacement )
%m = subdivideCellWalls( m, n )
%   Divide each segment of cell wall into segments of approximate length
%   dist, and displace them perpendicularly to the wall by displacement,
%   considered as a proportion of the segment length.
%
%   dist is expressed as a multiple of the average length of all wall
%   segments.  It defaults to 0.3. 
%
%   displacement defaults to 0.1.

    if isempty(m.secondlayer.cells)
        return;
    end

    if nargin < 2
        dist = 0.3;
    end
    
    if nargin < 3
        displacement = 0.1;
    end
    
    endpoints = m.secondlayer.cell3dcoords( m.secondlayer.edges(:,[1 2])', : );
    edgevectors = endpoints(2:2:end,:) - endpoints(1:2:end,:);
    edgedsq = sum( edgevectors.^2, 2 );
    edgedist = sqrt(edgedsq);
    
    absdist = dist*sum(edgedist)/length(edgedist);
    absdisp = displacement*absdist;
    
    segsperedge = round(edgedist/absdist);
    ptsperedge = max( segsperedge-1, 0 );
    numnewpts = sum( ptsperedge );
    
    newpts = zeros(numnewpts,3);
    newFEs = zeros(numnewpts,1);
    newbcs = zeros(numnewpts,3);
    newptsi = 0;
    fprintf( 1, 'Locating %d new points.\n', numnewpts );
    for i=1:length(edgedist)
        npts = ptsperedge(i);
        if npts > 0
            intermediates = repmat( endpoints(i+i-1,:), npts, 1 ) + ((1:npts)'/(npts+1))*edgevectors(i,:);
            % Need to use the displacement also.  For this we need to find
            % a direction perpendicular ot the edge and parallel to the
            % mesh surface.  To approximate the mesh surface, take the
            % normal vectors to the mesh at the two endpoints.
            vxs = m.secondlayer.edges(i,[1 2]);
            fes = m.secondlayer.vxFEMcell(vxs);
            normals = m.unitcellnormals(fes,:);
            normal = sum(normals,1)/2;
            transverse = makeframe( normal, edgevectors(i,:) );
            transverse = transverse/norm(transverse);
            transverses = ((rand(npts,1)*2-1)*absdisp)*transverse;
            
            newpts( (newptsi+1):(newptsi+npts), : ) = intermediates + transverses;
            for j=1:npts
                [ newFEs(newptsi+j), newbcs(newptsi+j,:), ~, ~ ] = findFE( m, newpts(newptsi+j,:), 'hint', fes );
            end
            newptsi = newptsi+npts;
            fprintf( 1, 'Located %d new points on edge %d.\n', npts, i );
        end
    end
%     for i=1:numnewpts
%         [ newFEs(i), newbcs(i,:), ~, ~ ] = findFE( m, newpts(i,:), 'hint', fes );
%     end
    
    numoldpts = size( m.secondlayer.cell3dcoords, 1 );
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; newpts ];
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; newFEs ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; newbcs ];
    numoldedges = size( m.secondlayer.edges, 1 );
    
    % Extend all other per-vertex data.
    
    fprintf( 1, 'Inserting new points.\n' );
    % Now we must splice these points into the cells.
    % For each subdivided edge, the original edge is reused to point to the
    % first new point.  New edges are created for the other segments.  The
    % cells on each side have their vxs and edges lists updated.
    % Extend all other per-edge data.
    m.secondlayer.generation( (numoldedges+1):(numoldedges+numnewpts) ) = 0;
    m.secondlayer.edgepropertyindex( (numoldedges+1):(numoldedges+numnewpts) ) = m.secondlayer.newedgeindex;
    m.secondlayer.interiorborder( (numoldedges+1):(numoldedges+numnewpts) ) = false;

    newptsi = 0;
    for i=1:length(edgedist)
        npts = ptsperedge(i);
        if npts > 0
            newptindexes = int32( (newptsi+1):(newptsi+npts) );
            newptsthisedge = numoldpts+newptindexes;
            newedgesthisedge = numoldedges+newptindexes;
            v1 = m.secondlayer.edges(i,1);
            v2 = m.secondlayer.edges(i,2);
            c1 = m.secondlayer.edges(i,3);
            c2 = m.secondlayer.edges(i,4);
            cev1 = m.secondlayer.cells(c1);
            cv1i = find( cev1.vxs==v1, 1 );
            cev1.vxs = [ cev1.vxs(1:cv1i), newptsthisedge, cev1.vxs((cv1i+1):end) ];
            cev1.edges = [ cev1.edges(1:cv1i), newedgesthisedge, cev1.edges((cv1i+1):end) ];
            m.secondlayer.cells(c1) = cev1;
            if c2 > 0
                cev2 = m.secondlayer.cells(c2);
                cv2i = find( cev2.vxs==v2, 1 );
                cev2.vxs = [ cev2.vxs(1:cv2i), newptsthisedge(end:-1:1), cev2.vxs((cv2i+1):end) ];
                cev2.edges = [ cev2.edges(1:(cv2i-1)), newedgesthisedge(end:-1:1), cev2.edges(cv2i:end) ];
                m.secondlayer.cells(c2) = cev2;
            end
            
            m.secondlayer.edges(i,:) = [ v1, numoldpts+newptsi+1, c1, c2 ];
            newedgedata = [ newptsthisedge', [ newptsthisedge(2:end)'; v2 ], c1+zeros(npts,1,'int32'), c2+zeros(npts,1,'int32') ];
            m.secondlayer.edges(newedgesthisedge,:) = newedgedata;
            m.secondlayer.generation( newedgesthisedge ) = m.secondlayer.generation( i );
            m.secondlayer.edgepropertyindex( newedgesthisedge ) = m.secondlayer.edgepropertyindex( i );
            m.secondlayer.interiorborder( newedgesthisedge ) = m.secondlayer.generation( i );

            newptsi = newptsi+npts;
        end
    end
    
    validmesh( m );
end
    