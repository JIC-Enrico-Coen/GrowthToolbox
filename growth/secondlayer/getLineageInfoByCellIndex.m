function lineageInfo = getLineageInfoByCellIndex( m, cellindexes )
%lineageInfo = getLineageInfoByCellIndex( m, cellids )
%   Obtain information about the lifetime and lineage of a set of cells.
%   The cells are identified by their indexes.  cellindexes defaults to the
%   set of all current existing cells.
%
%   See also: getLineageInfoByCellID


    if nargin < 2
        lineageInfo = getLineageInfoByCellID( m, m.secondlayer.cellid );
    else
        validindexes = (cellindexes>0) & (cellindexes <= getNumberOfCells(m));
        cellids = zeros(size(cellindexes));
        cellids(validindexes) = m.secondlayer.cellid(cellindexes(validindexes));
        lineageInfo = getLineageInfoByCellID( m, cellids);
    end
end
