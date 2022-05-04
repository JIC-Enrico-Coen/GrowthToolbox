function m = leaf_refinebioedges( m, varargin )
%m = leaf_refinebioedges( m, ... )
%   Subdivide the edges of the biological cells.
%
%   Options:
%
%   'refinement'   The number of segments that a wall segment of average
%           length should be divided into. This is one more than the number
%           of vertexes that will be interpolated into the wall. Wall
%           segments of other lengths will be divided into a proportionate
%           number of segments. This number does not need to be an integer.
%           A value of zero will perform no refinement.
%
%   'abslength'    The maximum length of any edge. Every edge will be
%           subdivided enough times for its subedges to be no more than
%           this length.  A value of zero or Inf will be ignored. The
%           default value is m.globalProps.bioAsublength.
%
%   If both 'refinement' and 'abslength' are given, each edge will be
%   subdivided enough times to satisfy both requirements.
%
%   'cells'   A list of indexes of cells (by default all of them). Only
%             refine the walls of the specified cells.
%
%   'edges'   A list of indexes of cell wall segments (by default all of
%             them). Only refine the specified wall segments.
%
%   If both 'cells' and 'edges' are specified, the sets of wall segments
%   they specify are combined. If just one is specified, the other is
%   taken to be empty. If neither is specified, all wall segments are
%   refined.

    if ~hasNonemptySecondLayer(m)
        return;
    end
    
    if size( m.secondlayer.vxFEMcell, 1 ) == 1
        xxxx = 1;
    end

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'refinement', 0, 'abslength', m.globalProps.bioAsublength, 'cells', [], 'edges', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'refinement', 'abslength', 'cells', 'edges' );
    if ~ok, return; end
    
    s.refinement = mean(s.refinement(:)); % In case of a mistaken multiple-value argument.
    
    haveRefinement = ~isempty(s.refinement) && (s.refinement > 1);
    haveAbslength = ~isempty(s.abslength) && (s.abslength < Inf) && (s.abslength ~= 0);
    
    if ~haveRefinement && ~haveAbslength
        % Nothing to do.
        return;
    end
    
    numcells = length(m.secondlayer.cells);
    numoldvertexes = length( m.secondlayer.vxFEMcell );
    numoldedges = size( m.secondlayer.edges, 1 );

    % Determine which edges we are to operate on.
    if isempty(s.cells) && isempty(s.edges)
        relEdgeMap = true(1,numoldedges);
        relCellIndexes = 1:numcells;
    else
        if islogical( s.cells )
            cellIndexes = reshape( find( s.cells ), [], 1 );
        else
            cellIndexes = s.cells;
        end
        if islogical( s.edges )
            edgeMap = s.edges;
        else
            edgeMap = false(1,numoldedges);
            edgeMap(s.edges) = true;
        end
%         relEdgeMap = false(1,numoldedges);
%         relEdgeMap(s.edges) = true;
        relEdgeMap = edgeMap;
        
        relEdgeMap( [ m.secondlayer.cells(s.cells).edges ] ) = true;
        relCellIndexes = reshape( unique( [ cellIndexes; reshape( m.secondlayer.edges(s.edges,[3 4]), [], 1 ) ] ), 1, [] );
        if relCellIndexes(1)==0
            relCellIndexes(1) = [];
        end
    end
    
    if isempty( relEdgeMap )
        % Nothing to do.
        return;
    end
    
    % Calculate the number of new vertexes and edges to be added to every
    % edge that is to be refined.
%     numRelEdges = sum(relEdgeMap); % size( m.secondlayer.edges, 1 );
    edgevecs = m.secondlayer.cell3dcoords( m.secondlayer.edges(relEdgeMap,1), : ) ...
                - m.secondlayer.cell3dcoords( m.secondlayer.edges(relEdgeMap,2), : );
    edgelengths = sqrt( sum( edgevecs.^2, 2 ) );
    
    segmentlength = Inf;
    if haveRefinement
        sortededgelengths = sort(edgelengths);
        medianlength = sortededgelengths(ceil(length(sortededgelengths)/2));
%         averagelength = sum(edgelengths)/numRelEdges;
        segmentlength = min( segmentlength, medianlength/s.refinement );
    end
    if haveAbslength
        segmentlength = min( segmentlength, s.abslength );
    end
    
    newVxsPerRelEdge = max( 1, round( edgelengths/segmentlength ) ) - 1;
    
    numNewVxsEdges = sum(newVxsPerRelEdge);
    % This is both the number of new vertexes and the number of new edges.
    
    if numNewVxsEdges==0
        % Nothing to do.
        return;
    end
    
    % All the other edges get no new subedges.
    newperedge = zeros( numoldedges, 1 );
    newperedge(relEdgeMap) = newVxsPerRelEdge;
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
    m.secondlayer.edges = [ m.secondlayer.edges; zeros( numNewVxsEdges, size(m.secondlayer.edges,2) ) ];
    m.secondlayer.vxFEMcell = m.secondlayer.vxFEMcell(:);
    m.secondlayer.vxFEMcell = [ m.secondlayer.vxFEMcell; zeros( numNewVxsEdges, size(m.secondlayer.vxFEMcell,2), 'int32' ) ];
    m.secondlayer.vxBaryCoords = [ m.secondlayer.vxBaryCoords; zeros( numNewVxsEdges, size(m.secondlayer.vxBaryCoords,2), 'single' ) ];
    m.secondlayer.cell3dcoords = [ m.secondlayer.cell3dcoords; zeros( numNewVxsEdges, size(m.secondlayer.cell3dcoords,2), 'single' ) ];
    m.secondlayer.interiorborder = [ m.secondlayer.interiorborder; false( numNewVxsEdges, size(m.secondlayer.interiorborder,2) ) ];
    m.secondlayer.generation = [ m.secondlayer.generation; zeros( numNewVxsEdges, size(m.secondlayer.generation,2), 'int32' ) ];
    m.secondlayer.edgepropertyindex = [ m.secondlayer.edgepropertyindex; ones( numNewVxsEdges, size(m.secondlayer.edgepropertyindex,2), 'int32' ) ];
    
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
    
    for ei=find(relEdgeMap)
        ss = starts(ei);
        es = ends(ei);
        % The positions of the new vertexes are distributed evenly along
        % the old edge.
        v1 = m.secondlayer.edges( ei, 1 );
        v2 = m.secondlayer.edges( ei, 2 );
        pos1 = m.secondlayer.cell3dcoords( v1, : );
        pos2 = m.secondlayer.cell3dcoords( v2, : );
        newpositions = alpha(ss:es)*pos1 + beta(ss:es)*pos2;
        m.secondlayer.cell3dcoords( subvxs(ss:es), : ) = newpositions;
        
        % The sub-edges border the same cells.
        m.secondlayer.edges( subedges(ss:es), [3 4] ) = repmat( m.secondlayer.edges(ei,[3 4]), newperedge(ei), 1 );
        
        % The sub-edges join the new vertexes.
        m.secondlayer.edges( subedges(ss:es), 1 ) = subvxs(ss:es)';
        m.secondlayer.edges( subedges(ss:es), 2 ) = [ subvxs((ss+1):es) m.secondlayer.edges( ei, 2 ) ]';
        m.secondlayer.edges( ei, 2 ) = subvxs(ss);
    end
    
    for ci=relCellIndexes
        vxs = m.secondlayer.cells(ci).vxs;
        edges = m.secondlayer.cells(ci).edges;
        sense = m.secondlayer.edges( edges, 1 )==vxs';
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
        m.secondlayer.cells(ci).edges = newedges;
        m.secondlayer.cells(ci).vxs = newvxs;
    end
    
    % Find which cell each new vertex belongs to.
    n = 0;
    for ei=1:numoldedges
        if newperedge(ei)==0
            continue;
        end
        ss = starts(ei);
        es = ends(ei);
        vxs = subvxs(ss:es);
        hint = m.secondlayer.vxFEMcell( m.secondlayer.edges(ei,[1 2]) );
        if false && (hint(1)==hint(2))
            ends = m.secondlayer.edges(ei,[1 2]);
            ci = hint(1);
            m.secondlayer.vxFEMcell(vxs) = ci;
            frac = (1:length(vxs))'/(length(vxs)+1);
            m.secondlayer.vxBaryCoords(vi,:) = frac*m.secondlayer.barycoords(ends(1),:) + (1-frac)*m.secondlayer.barycoords(ends(2),:);
        else
            if hint(2)==0
                hint = hint(1);
                if hint==0
                    xxxx = 1;
                end
            end
            for vi=vxs
                [ ci, bc, ~, ~ ] = findFE( m, m.secondlayer.cell3dcoords(vi,:), 'hint', hint );
                m.secondlayer.vxFEMcell(vi) = ci;
                m.secondlayer.vxBaryCoords(vi,:) = bc;
            end
        end
        n = n+1;
        if mod(n,100)==0
            fprintf( 1, '%s: %d edges refined.\n', mfilename(), n );
        end
    end
    
    m = calcCloneVxCoords( m, subvxs );

    m.secondlayer = extendCellIndexing( m.secondlayer );
end

