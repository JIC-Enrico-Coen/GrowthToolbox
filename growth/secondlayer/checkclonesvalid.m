function [ok,secondlayer] = checkclonesvalid( secondlayer )
%[ok,secondlayer] = checkclonesvalid( secondlayer )
%   Make consistency checks of secondlayer.

    ok = 1;
    numcells = length( secondlayer.cells );
    numedges = size( secondlayer.edges, 1 );
    numvxs = length( secondlayer.vxFEMcell );

    for ci=1:numcells
        secondlayer.cells(ci).vxs = secondlayer.cells(ci).vxs(:)';
        secondlayer.cells(ci).edges = secondlayer.cells(ci).edges(:)';
        
        nv = length( secondlayer.cells(ci).vxs );
        ne = length( secondlayer.cells(ci).edges );
        
        % Each cell must have the same number of vertexes as edges.
        if nv ~= ne
            complain2( 0, 'Cell %d has %d vertexes and %d edges. Numbers should be equal.', ...
                ci, nv, ne );
            ok = 0;
        end
        
        % Each cell must have at least three vertexes.
        if (ne < 3) || (nv < 3)
            complain2( 0, 'Cell %d has %d vertexes and %d edges. A cell must have at least three of each.', ...
                ci, nv, ne );
        end
    end
    
    
    % All indexes must be in range.
    for ci=1:numcells
        bad = find( (secondlayer.cells(ci).vxs > numvxs) | (secondlayer.cells(ci).vxs <= 0) );
        if bad
            complain2( 0, 'Cell %d has invalid vertex indices', ci );
            fprintf( 1, ' %d', bad );
            fprintf( 1, ': [' );
            fprintf( 1, ' %d', secondlayer.cells(ci).vxs );
            fprintf( 1, ' ]\n' );
            ok = 0;
        end
        bad = find( (secondlayer.cells(ci).edges > numedges) | (secondlayer.cells(ci).edges <= 0) );
        if bad
            complain2( 0, 'Cell %d has invalid edge indices', ci );
            fprintf( 1, ' %d', bad );
            fprintf( 1, ': [' );
            fprintf( 1, ' %d', secondlayer.cells(ci).edges );
            fprintf( 1, ' ]\n' );
            ok = 0;
        end
    end
    bad = find( (secondlayer.edges(:,1) > numvxs) | (secondlayer.edges(:,1) <= 0) );
    if bad
        complain2( 0, 'Edges with invalid first vertex index:\n' );
        fprintf( 1, '    edge %d bad vertex %d\n', [ bad, secondlayer.edges(bad,1) ]' );
        ok = 0;
    end
    bad = find( (secondlayer.edges(:,2) > numvxs) | (secondlayer.edges(:,2) <= 0) );
    if bad
        complain2( 0, 'Edges with invalid second vertex index:\n' );
        fprintf( 1, '    edge %d bad vertex %d\n', [ bad, secondlayer.edges(bad,2) ]' );
        ok = 0;
    end
    bad = find( (secondlayer.edges(:,3) > numcells) | (secondlayer.edges(:,3) <= 0) );
    if bad
        complain2( 0, 'Edges with invalid first cell index:\n' );
        fprintf( 1, '    edge %d bad cell %d\n', [ bad, secondlayer.edges(bad,3) ]' );
        ok = 0;
    end
    bad = find( secondlayer.edges(:,4) > numcells );
    if bad
        complain2( 0, 'Edges with invalid second cell index:\n' );
        fprintf( 1, '    edge %d bad cell %d\n', [ bad, secondlayer.edges(bad,4) ]' );
        ok = 0;
    end
        
    
    % Each edge of each cell joins the corresponding vertexes of that cell,
    % and the edge data references the cell.
    lostEdges = true(1,numedges);
    lostVxs = true(1,numvxs);
    for ci=1:numcells
        cev = secondlayer.cells(ci);
        if any((cev.vxs < 1) | (cev.vxs > numvxs))
            complain2( 0, 'Cell %d contains invalid vertexes.', ci );
            fprintf( 1, '    [' );
            fprintf( 1, ' %d', cev.vxs );
            fprintf( 1, ' ]\n' );
            ok = 0;
            cev.vxs = cev.vxs(cev.edges>=1);
        end
        if any(cev.edges < 1)
            complain2( 0, 'Cell %d contains invalid edges.', ci );
            fprintf( 1, '    [' );
            fprintf( 1, ' %d', cev.edges );
            fprintf( 1, ' ]\n' );
            ok = 0;
            cev.edges = cev.edges(cev.edges>=1);
        end
        if isempty(cev.vxs) || isempty(cev.edges)
            continue;
        end
        lostEdges( cev.edges ) = false;
        lostVxs( cev.vxs ) = false;
        nv = length( cev.vxs );
        cellvxends = cev.vxs([(1:nv)',[2:nv,1]']);
        flips = cellvxends(:,1) > cellvxends(:,2);
        cellvxends(flips,:) = cellvxends(flips,[2 1]);
      % cellvxends = sort( cev.vxs([(1:nv)',[2:nv,1]']), 2 );
        celledgeends = secondlayer.edges( cev.edges, [1 2] );
        flips = celledgeends(:,1) > celledgeends(:,2);
        celledgeends(flips,:) = celledgeends(flips,[2 1]);
        badEdgeVxs = cellvxends ~= celledgeends;
        if any( badEdgeVxs(:) )
            for cvi=1:nv
                ei = cev.edges(cvi);
                e = secondlayer.edges(ei,:);
                if badEdgeVxs(cvi,1) || badEdgeVxs(cvi,2)
                    vi = cev.vxs(cvi);
                    cvi1 = mod(cvi,nv) + 1;
                    vi1 = cev.vxs(cvi1);
                    complain2( 0, 'Cell %d edge %d (%d) should join vertexes %d and %d, but joins %d and %d. Edge = [ %d %d %d %d ]\n', ...
                        ci, cvi, ei, vi, vi1, e([1 2]), e );
                    ok = 0;
                end
                if (e(3) ~= ci) && (e(4) ~= ci)
                    complain2( 0, 'Cell %d edge %d (%d) should have cell %d on one side, but has cells %d and %d.', ...
                        ci, cvi, ei, ci, e([3 4]) );
                    ok = 0;
                end
            end
        end
    end
    
    tweaked = false;
    % Every edge is an edge of at least one cell.
    if any(lostEdges)
        complain2( 0, '%d edges are not referenced by any cell.', sum(lostEdges) );
      % ok = false;
        if nargout >= 2
            newToOldEdge = find(~lostEdges);
            oldToNewEdge = zeros(1,numedges);
            oldToNewEdge(newToOldEdge) = 1:length(newToOldEdge);
            for ci=1:numcells
                secondlayer.cells(ci).edges = oldToNewEdge( secondlayer.cells(ci).edges );
            end
            secondlayer.edges = secondlayer.edges(~lostEdges,:);
            numedges = size( secondlayer.edges, 1 );
            tweaked = true;
        end
    end
    
    % Two edges do not join the same vertexes.
    [e,p] = sortrows( sort( secondlayer.edges(:,[1 2]), 2 ) );
    dupedgemap = all( e(1:(end-1),:)==e(2:end,:), 2 );
    if any( dupedgemap )
        dupedgelist = find(dupedgemap);
        dupedgelist = p( [ dupedgelist, dupedgelist+1 ] )';
        ok = false;
        complain2( 0, 'validmesh:duplicateedges', ...
            'There are multiple edges joining the same vertexes: %d examples.', size(dupedgelist,2) );
        fprintf( 1, 'Bad edge pairs:\n' );
        fprintf( 1, '    [%d,%d]\n', dupedgelist );
    end
    
    % Every edge has a generation index.
    if isfield( secondlayer, 'generation' )
        r = checksize( numedges, length(secondlayer.generation), 'secondlayer.generation' );
        if ~r
            secondlayer.generation = procrustesHeight( secondlayer.generation, numedges );
        end
        ok = r && ok;
    end
    if isfield( secondlayer, 'generation' )
        if numedges ~= length(secondlayer.generation)
            complain2( 0, 'There are %d edges but %d generation indexes.', ...
                numedges, length(secondlayer.generation) );
            ok = false;
        end
    end
    if isfield( secondlayer, 'edgepropertyindex' )
        r = checksize( numedges, length(secondlayer.edgepropertyindex), 'secondlayer.edgepropertyindex' );
        if ~r
            secondlayer.edgepropertyindex = procrustesHeight( secondlayer.edgepropertyindex, numedges, 1 );
        end
        ok = r && ok;
    end
    if isfield( secondlayer, 'interiorborder' )
        r = checksize( numedges, length(secondlayer.interiorborder), 'secondlayer.interiorborder' );
        if ~r
            secondlayer.interiorborder = procrustesHeight( secondlayer.interiorborder, numedges );
        end
        ok = r && ok;
    end
    
    % Every vertex is a vertex of at least one cell.
    if any(lostVxs)
        complain2( 0, '%d vertexes are not referenced by any cell.', sum(lostVxs) ); %#ok<*FNDSB>
      % ok = false;
        if nargout >= 2
            newToOldVx = find(~lostVxs);
            oldToNewVx = zeros(1,numvxs);
            oldToNewVx(newToOldVx) = 1:length(newToOldVx);
            for ci=1:numcells
                secondlayer.cells(ci).vxs = oldToNewVx( secondlayer.cells(ci).vxs );
            end
            secondlayer.vxFEMcell = secondlayer.vxFEMcell( ~lostVxs );
            secondlayer.vxBaryCoords = secondlayer.vxBaryCoords( ~lostVxs, : );
            secondlayer.cell3dcoords = secondlayer.cell3dcoords( ~lostVxs, : );
            secondlayer.edges(:,1:2) = oldToNewVx( secondlayer.edges(:,1:2) );
            numvxs = length( secondlayer.vxFEMcell );
            tweaked = true;
        end
    end
    
    % Every vertex is a vertex of at least one edge.
    lostVxs = true(1,numvxs);
    lostVxs( secondlayer.edges(:,[1 2]) ) = false;
  % for ei=1:numedges
  %     lostVxs( secondlayer.edges(ei,[1 2]) ) = false;
  % end
    if any(lostVxs)
        complain2( 0, '%d vertexes are not referenced by any edge.', sum(lostVxs) );
        ok = false;
    end
    
    [ok1,secondlayer] = checkbioedgehandedness( secondlayer );
    ok = ok && ok1;
    
    if ok && tweaked && (nargout >= 2)
        fprintf( 1, 'About to redo checkclonesvalid.\n' );
        ok = checkclonesvalid( secondlayer );
    end
    
    cellidok = checklineagevalid( secondlayer );
    if ~cellidok
        xxxx = 1;
    end

    ok = ok && cellidok;
    
    % The cell value dictionary must be internally consistent.
    okdict = validdictionary( secondlayer.valuedict );
    % The cell value dictionary must be consistent with the number of cell
    % values.
    if okdict
        numcellvalues = size( secondlayer.cellvalues, 2 );
        numcellvaluenames = length( secondlayer.valuedict.index2NameMap );
        if numcellvalues ~= numcellvaluenames
            ok = false;
            complain2( 0, 'Number of cell values (%d) is not equal to number of cell value names (%d).\n    Fixed by taking the latter to be correct.', ...
                numcellvalues, numcellvaluenames );
            secondlayer.cellvalues = procrustesWidth( secondlayer.cellvalues, numcellvaluenames );
        end
    end

    ok = ok && okdict;
    
    
    ok = checkindexdataInternal( 'cell', secondlayer.celldata, numcells ) && ok;
    ok = checkindexdataInternal( 'edge', secondlayer.edgedata, numedges ) && ok;
    ok = checkindexdataInternal( 'vertex', secondlayer.vxdata, numvxs ) && ok;
end

function ok = checkindexdataInternal( name, d, len )
    ok = true;
    if isempty(d), return; end
    if length(d.genindex) ~= len
        complain2( 0, 'There are %d %ss but %d generation indexes.', ...
            len, name, length(d.genindex) );
        ok = false;
    end
    if size(d.parent,1) ~= len
        complain2( 0, 'There are %d %ss but parent data for %d.', ...
            len, name, size(d.parent,1) );
        ok = false;
    end
    if size(d.values,1) ~= len
        complain2( 0, 'There are %d %ss but values for %d.', ...
            len, name, size(d.values,1) );
        ok = false;
    end
    maxgen = max( d.genindex );
    if ~isempty(maxgen) && (maxgen > d.genmaxindex)
        complain2( 0, 'The maximum %s generation index should be %d but one has an index of %d.', ...
            name, d.genmaxindex, maxgen );
        ok = false;
    end
end
