function ci = cellIndexFromCellGenIndex( m, cellgenindex )
%ci = cellIndexFromCellGenIndex( m, cellgenindex )
%   Given the generation index of a cell, find its index in the list of all
%   cells.  Multiple values can be given; the result will be an array the
%   same shape as cellgenindex.  For values of cellgenindex not
%   corresponding to any existing cell, 0 is returned.
%
%   See also: invertArray

    ci = invertArray( m.secondlayer.cellgenindex, cellgenindex );
end
