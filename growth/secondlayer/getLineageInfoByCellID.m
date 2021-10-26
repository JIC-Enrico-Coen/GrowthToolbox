function lineageInfo = getLineageInfoByCellID( m, cellids )
%lineageInfo = getLineageInfoByCellID( m, cellids )
%   Obtain information about the lifetime and lineage of a set of cells.
%   The cells are identified by their ids, not their indexes.  cellids
%   defaults to the set of all cell ids, including cells that no longer
%   exist or do not yet exist.
%
%   The result is a structure with the following fields. Assume cellids
%   has N elements.
%
%   cellid:     N*1, integer.  The id of the cell
%   cellindex:  N*1, integer.  The index of the cell in the current state
%                              of the mesh.
%   parent:     N*1, integer.  The id of the cell's parent.
%   daughters:  N*2, integer.  The ids of the cell's two daughters.
%   lifetime:   N*1, double.   The time the cell was created and the time
%                              it split, was deleted, or the simulation
%                              ended.
%
%   Where the information does not exist for any reason, integer fields are
%   zero and real fields are NaN.
%
%   When a simulation is run, the information that getLineageInfoByCellID
%   reads is accumulated in the static data.  So when you reload an earlier
%   stage, lineage information for later stages is still there.
%
%   When you perform a simulation step, all lineage information relating to
%   later times is deleted as being no longer valid.  This also happens
%   when you load a previously computed run of the simulation.
%
%   See also: getLineageInfoByCellIndex

    if nargin < 2
        cellids = (1:length(m.secondlayer.cellparent))';
    end
    numcells = numel(cellids);

    lineageInfo = struct( ...
        'cellid', cellids(:), ...
        'cellindex', zeros(numcells,1,'int32'), ...
        'parent', zeros(numcells,1,'int32'), ...
        'daughters', zeros(numcells,2,'int32'), ...
        'lifetime', nan( numcells, 2 ) );
    
    maxcellid = length( m.secondlayer.cellparent );
    validcellidmask = cellids(:) <= maxcellid;
    validcellidarray = cellids(validcellidmask);
    lineageInfo.cellindex(validcellidmask) = m.secondlayer.cellidtoindex(validcellidarray);
    lineageInfo.parent(validcellidmask) = m.secondlayer.cellparent(validcellidarray);
    lineageInfo.lifetime(validcellidmask,:) = m.secondlayer.cellidtotime(validcellidarray,:);
    for i=1:numel(cellids)
        if ~validcellidmask(i)
            % Cell is not known to ever exist.
            continue;
        end
        cellid = cellids(i);
%         lineageInfo.parent(i) = m.secondlayer.cellparent(cellid);
        daughters = find( m.secondlayer.cellparent==cellid, 2 );
        lineageInfo.daughters(i,1:length(daughters)) = daughters;
%         lineageInfo.lifetime(i,:) = m.secondlayer.cellidtotime(cellid,:);
    end
end
