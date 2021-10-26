function sl1 = refineCells( sl, varargin )
%sl = refineCells( sl, refinement )

    sl1 = sl;
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'refinement', 0, 'abslength', Inf );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'refinement', 'abslength' );
    if ~ok, return; end
    
    s.refinement = max( 0, round( s.refinement ) );
    if (s.refinement==0) && isinf( s.abslength )
        return;
    end
    
    numdims = size(sl.pts, 2 );
    numcells = size( sl.cellvxs, 1 );
    numoldvxs = size( sl.pts, 1 );
    
    % Force the vertex list for each cell to end with at least one NaN.
    sl.cellvxs = [ sl.cellvxs, nan( numcells, 1 ) ];

    % Concatenate all the cell vertex lists.
    aa = reshape( sl.cellvxs', [], 1 );
    aanan = isnan(aa);
    % Find where each cell begins and ends.
    ends = find( ~aanan(1:(end-1)) & aanan(2:end) );
    starts = [1; 1+find( aanan(1:(end-1)) & ~aanan(2:end) ) ];

    % Create edgecells, mapping each edge to the cell it belongs to.
    numedges = length(aa)-1;
    edgecells = zeros( numedges, 1 );
    for i=1:length(starts)
        edgecells( starts(i):ends(i) ) = i;
    end
    
    % Create edgevxs, mapping each directed edge to the pair of its
    % vertexes.
    edgevxs = [aa(1:(end-1)) aa(2:end)];
    edgevxs(ends,2) = edgevxs(starts,1);
    nonedges = isnan(edgevxs(:,1));
    edgevxs( nonedges, : ) = [];
    edgecells( nonedges ) = [];
    
    % Create uedgevxs, mapping each undirected edge to the pair of its
    % vertexes.
    % uedgesense specifies for each directed edge, whether its sense agrees
    % with the ordering of the undirected edge.
    [uedgevxs,ia,ic] = unique( sort( edgevxs, 2 ), 'rows' );
    uedgesense = edgevxs(ia,1) == uedgevxs( :, 1 );
    uedgesense = edgevxs(:,1) == uedgevxs( ic, 1 );
    numuedges = size(uedgevxs,1);

    % Calculate the number of segments each undirected edge should be
    % divided into.
    uedgelengths = sqrt( sum( (sl.pts( uedgevxs(:,1), : ) - sl.pts( uedgevxs(:,2), : )).^2, 2 ) );
    meanlength = mean( uedgelengths );
    if s.refinement==0
        targetlength = s.abslength;
    else
        targetlength = min( meanlength/s.refinement, s.abslength );
    end
    segments = max( 1, round( uedgelengths/targetlength ) );
    if all(segments==1)
        return;
    end
    numnewsegments = sum(segments) - length(segments);
    newvxindexes = (numoldvxs+1):(numoldvxs+numnewsegments);
    
    % Calculate where the new vertexes do. There is one for every segment
    % added to an edge.
    newpts = zeros( numnewsegments, numdims );
    
    npi = 0;
    for i=1:numuedges
        % For each undirected edge, the new vertexes are placed at equal
        % intervals along it.
        firstvx = sl.pts( uedgevxs(i,1), : );
        edgevec = sl.pts( uedgevxs(i,2), : ) - firstvx;
        numnewptsthisedge = segments(i)-1;
        newpts( (npi+1):(npi+numnewptsthisedge), : ) = firstvx + (1:numnewptsthisedge)' * edgevec;
        npi = npi+numnewptsthisedge;
    end
    
    % For each undirected edge, calculate the list of vertexes representing
    % the multi-segment path it is to be replaced by.
    newuedgelets = cell( numuedges, 1 );
    st = 0;
    for i=1:numuedges
        st1 = st+segments(i)-1;
        newuedgelets{i} = [ uedgevxs(i,1), newvxindexes( (st+1):st1 ), uedgevxs(i,2) ];
        st = st1;
    end
    
    % For each directed edge, calculate the list of vertexes representing
    % the multi-segment path it is to be replaced by. Thus will be the list
    % of vertexes for the undirected edge, either reversed in order or not
    % according to the edge sense. After the possible reversal, we omit the
    % last vertex.
    newedgelets = newuedgelets( ic );
    for i=1:length(newedgelets)
        if uedgesense(i)
            newedgelets{i} = newedgelets{i}(1:(end-1));
        else
            newedgelets{i} = newedgelets{i}(end:-1:2);
        end
    end
    newedgelets = cellToRaggedArray( newedgelets, NaN, true );
    
    % Now for each cell, we must replace each edge by the corresponding
    % sequence of edges.
    % First, decompose edgecells into the segments for each cell.
    ends = find( edgecells(1:(end-1)) ~= edgecells(2:end) );
    starts = [1; ends+1];
    ends = [ends; length(edgecells)];
    % Allocate newcellvxs to hold the new mapping from cells to vertex
    % lists.
    newcellvxs = cell( numcells, 1 );
    for i=1:length(starts)
        foo = reshape( newedgelets( starts(i):ends(i), : )', 1, [] );
        foo( isnan(foo) ) = [];
        newcellvxs{i} = foo;
    end
    newcellvxs = cellToRaggedArray( newcellvxs, NaN, true );
    
    sl1 = struct( 'pts', [sl.pts; newpts], 'cellvxs', newcellvxs );
end
