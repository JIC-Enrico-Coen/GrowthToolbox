function unionData = mergeSpreadsheetData( olddata, newdata )
%unionData = mergeSpreadsheetData( olddata, newdata )
%
% OLDDATA and NEWDATA are assumed to be cell arrays in which the first
% column is a header column, consisting of names for the rows. The
% remainder is columns of data.
%
% OLDDATA and NEWDATA do not necessarily contain the same row names, or in
% the same order. The two are united into a new set of row names, as far as
% possible in the same order as in OLDDATA and NEWDATA. The new data are
% then added to the right of the old data.

    if isempty(olddata)
        unionData = newdata;
    elseif isempty(newdata)
        unionData = olddata;
    else
        numolddata = size(olddata,2)-1;
        oldheadings = olddata(:,1);
        newheadings = newdata(:,1);
        numnewdata = size(newdata,2)-1;
        [unionheadings, ~, ic] = unique( [oldheadings; newheadings], 'stable' );
        indexold = ic(1:length(oldheadings));
        indexnew = ic((length(oldheadings)+1):end);
        unionData = cell( length(unionheadings), numolddata + numnewdata );
        unionData(:,1) = unionheadings';
        unionData( indexold, 2:(numolddata+1) ) = olddata(:,2:end);
        unionData( indexnew, (numolddata+2):(numolddata+1+numnewdata) ) = newdata(:,2:end);
    end
end