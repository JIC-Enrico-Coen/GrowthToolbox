function [divides,infoexists] = cellDividesBetween( m, t1, t2, cellindexes )
%[divides,infoexists] = cellDividesBetween( m, cellid, t1, t2 )
%   cellid is a cell index or vector of cell indexes, and defaults to all
%   of the cells.
%
%   t1 and t2 are times or vectors of times the same length as cellid.
%
%   divides will be a boolean vector of the same length as cellid, true for
%   those cells that divide in the half-open interval [t1,t2).
%
%   infoexists will be a boolean vector of the same size indicating whether
%   the requested information exists for each cell.

    if nargin < 4
        cellindexes = 1:length(m.secondlayer.cellid);
    end
    
    t1 = min( t1, m.globalProps.validitytime );
    t2 = min( t2, m.globalProps.validitytime );
    
    lineageInfo = getLineageInfoByCellIndex( m, cellindexes );
    infoexists = lineageInfo.lifetime(:,2) <= m.globalProps.validitytime;  % ~isnan(lineageInfo.daughters(:,1));
    divides = infoexists & (t1 <= lineageInfo.lifetime(:,2)) & (lineageInfo.lifetime(:,2) < t2);
end
