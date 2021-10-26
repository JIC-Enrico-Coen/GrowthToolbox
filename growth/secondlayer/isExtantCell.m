function extant = isExtantCell( m, cellids )
%extant = isExtantCell( m, cellids )
%   Determine which of a given set of cells, identified by their ids, are
%   currently extant.  cellids defaults to all of the cells that have ever
%   existed.

    if nargin < 2
        extant = true(size(m.secondlayer.cellparent));
    else
        maxcellid = length(m.secondlayer.cellparent);
        extant = (cellids > 0) & (cellids <= maxcellid);
    end
    remainingcellids = cellids(extant);
    if ~isempty(remainingcellids)
        begun = m.secondlayer.cellidtotime(remainingcellids,1) <= m.globalDynamicProps.currenttime;
        notended = m.secondlayer.cellidtotime(remainingcellids,2) >= m.globalDynamicProps.currenttime;
        extant(extant) = begun & notended;
    end
end