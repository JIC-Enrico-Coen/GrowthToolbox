function sl = refineBasicCellularLayer( sl, s )
%sl = refineBasicCellularLayer( sl, s )
%   INCOMPLETE.

% sl contains only pts and cellvxs
    numcells = size( sl.cellvxs, 1 );
    
    for ci=1:numcells
        vi = sl.cells(
    end
    
    
    return;
    
    
    numoldvertexes = 0;
    numoldedges = 0;

    % Determine which edges we are to operate on.
    relEdgeMap = true(1,numoldedges);
    
    % Calculate the number of new vertexes and edges to be added to every
    % edge that is to be refined.
%     numRelEdges = sum(relEdgeMap); % size( m_secondlayer.edges, 1 );
    edgevecs = sl.cell3dcoords( sl.edges(relEdgeMap,1), : ) ...
                - sl.cell3dcoords( sl.edges(relEdgeMap,2), : );
    edgelengths = sqrt( sum( edgevecs.^2, 2 ) );
    
    segmentlength = Inf;
    if s.refinement > 0
        sortededgelengths = sort(edgelengths);
        medianlength = sortededgelengths(ceil(length(sortededgelengths)/2));
%         averagelength = sum(edgelengths)/numRelEdges;
        segmentlength = min( segmentlength, medianlength/s.refinement );
    end
    if s.abslength > 0
        segmentlength = min( segmentlength, s.abslength );
    end
    
    newperRelEdge = max( 1, round( edgelengths/segmentlength ) ) - 1;
    
    numNewVxsEdges = sum(newperRelEdge);
    % This is both the number of new vertexes and the number of new edges.
    
    if numNewVxsEdges==0
        % Nothing to do.
        return;
    end
    
    % All the other edges get no new subedges.
    newperedge = zeros( numoldedges, 1 );
    newperedge(relEdgeMap) = newperRelEdge;
    relEdgeMap = newperedge' > 0;
    
    % Henceforth we deal with all edges.  Edges that are not to be refined
    % are processed with a refinement value of 1.  This is simpler than
    % trying to operate just on the specified edges.
    
    
    % Now we want an array listing the parent edges of all the new edges.
    ends = cumsum( newperedge );
    starts = [1; (ends(1:end-1)+1)];
    % starts and ends both have length numoldedges.
    % starts(ei):ends(ei) is a set of indexes into both subvxs and
    % subedges, identifying the new vertexes and edges added to edge ei.
    % For unrefined edges the range is empty.
    
    % Extend all the per-vertex and per-edge arrays to hold the new data.
    sl.edges = [ sl.edges; zeros( numNewVxsEdges, size(sl.edges,2) ) ];
    sl.vxFEMcell = [ sl.vxFEMcell; zeros( numNewVxsEdges, size(sl.vxFEMcell,2), 'int32' ) ];
    sl.vxBaryCoords = [ sl.vxBaryCoords; zeros( numNewVxsEdges, size(sl.vxBaryCoords,2), 'single' ) ];
    sl.cell3dcoords = [ sl.cell3dcoords; zeros( numNewVxsEdges, size(sl.cell3dcoords,2), 'single' ) ];
    sl.interiorborder = [ sl.interiorborder; false( numNewVxsEdges, size(sl.interiorborder,2) ) ];
    sl.generation = [ sl.generation; zeros( numNewVxsEdges, size(sl.generation,2), 'int32' ) ];
    sl.edgepropertyindex = [ sl.edgepropertyindex; ones( numNewVxsEdges, size(sl.edgepropertyindex,2), 'int32' ) ];
    
    % interiorborder will need updating.
    % indexededgeproperties?
    % edgedata?
    % vertexdata?
    
    % Calculate the interpolation coefficients.
    beta = zeros( numNewVxsEdges, 1 );
%     oldedge = zeros( numnew, 1 );
%     k = 0;
    for i=1:length(starts)
        ss = starts(i);
        es = ends(i);
%         for j=ss:es
%             k = k+1;
%             oldedge(k) = i;
%         end
        n = newperedge(i);
        beta(ss:es) = (1:n)'/(n+1);
    end
    alpha = 1-beta;
    
    subedges = numoldedges + (1:numNewVxsEdges);
    subvxs = numoldvertexes + (1:numNewVxsEdges);
    
    for ei=find(relEdgeMap) % 1:numoldedges % 
        ss = starts(ei);
        es = ends(ei);
        % The positions of the new vertexes are distributed evenly along
        % the old edge.
        v1 = sl.edges( ei, 1 );
        v2 = sl.edges( ei, 2 );
        pos1 = sl.cell3dcoords( v1, : );
        pos2 = sl.cell3dcoords( v2, : );
        newpositions = alpha(ss:es)*pos1 + beta(ss:es)*pos2;
        sl.cell3dcoords( subvxs(ss:es), : ) = newpositions;
        
        % The sub-edges border the same cells.
        sl.edges( subedges(ss:es), [3 4] ) = repmat( sl.edges(ei,[3 4]), newperedge(ei), 1 );
        
        % The sub-edges join the new vertexes.
        sl.edges( subedges(ss:es), 1 ) = subvxs(ss:es)';
        sl.edges( subedges(ss:es), 2 ) = [ subvxs((ss+1):es) sl.edges( ei, 2 ) ]';
        sl.edges( ei, 2 ) = subvxs(ss);
    end
    
    for ci=1:numcells
        vxs = sl.cells(ci).vxs;
        edges = sl.cells(ci).edges;
        sense = sl.edges( edges, 1 )==vxs';
        ss = starts(edges);
        es = ends(edges);
        extra = sum(es-ss+1);
        numev = length(edges)+extra;
        newedges = zeros(1,numev);
        newvxs = zeros(1,numev);
        k = 0;
        for i=1:length(edges)
            ne = [ edges(i), subedges(ss(i):es(i)) ];
            nv = [ vxs(i), subvxs(ss(i):es(i)) ];
            nn = length(ne);
            if ~sense(i)
                ne = ne( end:-1:1 );
                nv = nv( [1 end:-1:2] );
            end
            newedges( (k+1):(k+nn) ) = ne;
            newvxs( (k+1):(k+nn) ) = nv;
            k = k+nn;
        end
        sl.cells(ci).edges = newedges;
        sl.cells(ci).vxs = newvxs;
    end
end
