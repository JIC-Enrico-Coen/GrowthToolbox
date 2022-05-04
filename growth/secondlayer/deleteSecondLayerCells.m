function secondlayer = deleteSecondLayerCells( secondlayer, cellsToDelete, t )
%secondlayer = deleteSecondLayerCells( secondlayer, cellsToDelete )
%   cellsToDelete is a bitmap or list of the cells to delete from the
%   second layer.  It defaults to all cells.  If all cells are deleted, so
%   is lineage history.  Otherwise, the third argument must be present, and
%   is the time at which these cells are being deleted (which can be
%   obtained from m.globalDynamicProps.currenttime).  This is required
%   in order to maintain the lifetime information for each cell.

    if ~isNonemptySecondLayer( secondlayer )
        return;
    end

    numcells = length( secondlayer.cells );
    numedges = size( secondlayer.edges, 1 );
    numvxs = length( secondlayer.vxFEMcell );
    
    if nargin < 2
        retainedCellMap = false(1,numcells);
        cellsToDelete = true(1,numcells);
    else
        retainedCellMap = true(1,numcells);
        retainedCellMap(cellsToDelete) = false;
    end
    
%     if ~any(retainedCellMap)
%         secondlayer = newemptysecondlayer( secondlayer );
%         return;
%     end
    
    if nargin < 3
        t = NaN;
    end
    
    cellsToKeep = find(retainedCellMap);
    deleteall = isempty(cellsToKeep);
    
    if false && deleteall
        secondlayer = newemptysecondlayer();
    end
    
    % Find all vertexes that belong to any retained cell.
    [ ~, oldToNewCell ] = makeRenumbering( retainedCellMap );
    retainedVxMap = false(1,numvxs);
    for i=cellsToKeep
        retainedVxMap(secondlayer.cells(i).vxs) = true;
    end
    [ ~, oldToNewVx ] = makeRenumbering( retainedVxMap );
    retainedEdgeMap = false( 1, numedges );
    for i=cellsToKeep
        retainedEdgeMap(secondlayer.cells(i).edges) = true;
    end
    [ ~, oldToNewEdge ] = makeRenumbering( retainedEdgeMap );
    
    secondlayer = keepBioElements( secondlayer, retainedCellMap, retainedEdgeMap, retainedVxMap );
    
    secondlayer.edges(:,1:2) = renumberArray( secondlayer.edges( :, 1:2 ), oldToNewVx );
%     if any( any( secondlayer.edges(:,[1,2]) <= 0, 2 ) )
%         xxxx = 1;
%     end
    secondlayer.edges(:,[3 4]) = renumberNzArray( secondlayer.edges(:,[3 4]), oldToNewCell );
    flip = secondlayer.edges(:,3) <= 0;
    secondlayer.edges(flip,:) = secondlayer.edges(flip,[2 1 4 3]);
    
    numcells = length( secondlayer.cells );
    for ci=1:numcells
        secondlayer.cells(ci).vxs = oldToNewVx( secondlayer.cells(ci).vxs );
        secondlayer.cells(ci).edges = oldToNewEdge( secondlayer.cells(ci).edges );
    end
    
    secondlayer.celldata = keepitems( secondlayer.celldata, retainedCellMap );
    secondlayer.edgedata = keepitems( secondlayer.edgedata, retainedEdgeMap );
    secondlayer.vxdata = keepitems( secondlayer.vxdata, retainedVxMap );
    

    % Deleted cells no longer have an index.
    
    secondlayer1 = secondlayer;
    
    if deleteall
        secondlayer.cellid = zeros(0,1,'int32');
        secondlayer.cellparent = zeros(0,1,'int32');
        secondlayer.cellidtoindex = zeros(0,1,'int32');
        secondlayer.cellidtotime = zeros(0,2,'double');
        secondlayer = newemptybiodata( secondlayer, true );
    else
        cellidtodelete = secondlayer.cellid( cellsToDelete );
        secondlayer.cellid( cellsToDelete ) = [];
        secondlayer.cellidtoindex(:) = 0;
        secondlayer.cellidtoindex( secondlayer.cellid ) = (1:numcells)';
        secondlayer.cellidtotime( cellidtodelete, 2 ) = t;
    end

    [ok,secondlayer2] = checkclonesvalid( secondlayer );
    secondlayer = secondlayer2;
%     if ~ok
%         xxxx = 1;
%     end
end

function d = keepitems( d, keep )
    d.genindex = d.genindex( keep );
    d.parent = d.parent( keep, : );
    d.values = d.values( keep, : );
end


