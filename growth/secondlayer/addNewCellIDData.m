function m = addNewCellIDData( m, numnewcells )
%m = addNewCellIDData( m, newcellindexes )
%   Create lineage data for the given cells, presumed to have just been
%   added to the cellular layer.

    if numnewcells <= 0
        return;
    end
    
    numcells = length(m.secondlayer.cells) - numnewcells;
    if numcells < 0
        numnewcells = numnewcells + numcells;
        numcells = 0;
    end
    newcellindexes = ((numcells+1):(numcells+numnewcells))';
    maxcellid = length( m.secondlayer.cellidtoindex );
    newcellids = ((maxcellid+1):(maxcellid+numnewcells))';
    
    % cellid is a unique index for every cell that exists at any time in
    % the bio layer.  maxcellid is the largest id that has so far been used.
    m.secondlayer.cellid(newcellindexes,1) = newcellids;
    
    % cellidtoindex is indexed by cell id and gives values in current cell
    % indexes.  A cell that does not currently exist is given an index of 0.
    % m.secondlayer.cellid and m.secondlayer.cellidtoindex are inverses of
    % each other for currently existing cells:
    %     m.secondlayer.cellidtoindex( m.secondlayer.cellid )
    % should be equal to (1:numcells)'.
    % m.secondlayer.cellid( m.secondlayer.cellidtoindex(m.secondlayer.cellidtoindex>0) )
    % should be equal to find(m.secondlayer.cellidtoindex>0).
    m.secondlayer.cellidtoindex(newcellids,1) = newcellindexes;
    
    % cellparent is indexed by cell id and its value is a cell
    % id, the parent whose splitting gave rise to this cell.  If there is
    % no parent, the value is 0.
    m.secondlayer.cellparent(newcellids,1) = zeros(numnewcells,1,'int32');
    
    % celldaughters is indexed by cell id.  It contains the ids of its
    % daughter cells, if any, otherwise zeros.
%     m.secondlayer.celldaughters(newcellids,[1 2]) = 0;
    
    % cellidtotime is indexed by cell id.  It contains two values for
    % every cell that has existed so far: begin time (creation ab initio or
    % by splitting its parent cell) and end time (splitting or deletion).
    % For cells that have not yet ended, the end time is the current time.
    m.secondlayer.cellidtotime(newcellids,[1 2]) = m.globalDynamicProps.currenttime+zeros(numnewcells,2,'double');
end
