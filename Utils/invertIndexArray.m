function [b,lengths] = invertIndexArray( a, m, type )
%b = invertIndexArray( a, m )
%   A is an N*K array that maps each integer in 1:N to a list of integers
%   in the range 1:M.  If M is omitted it defaults to the maximum value in
%   A.
%
%   TYPE can be either 'cell' or 'array'.  If cell, the result is a cell
%   array of length M, mapping each integer in 1:M to the list of rows of A
%   in which it appears.  If 'array', the result is returned as an M*L
%   array, with each row being padded out with zeros as necessary. The
%   default is 'cell'. LENGTHS contains the length of each list.
%
%   Zero elements of A are ignored.
%
%   For each cell/row of B, the indexes are listed in increasing order.

    n = size(a,1);
    k = size(a,2);
    if (nargin < 2) || isempty(m)
        m = max(a(:));
    end
    iscell = (nargin < 3) || isempty(type) || strcmp( type, 'cell' );
    xx = sortrows( [ a(:), repmat( (1:n)', k, 1 ) ] );
    xxstart = find( xx(:,1) > 0, 1 );
    xx(1:(xxstart-1),:) = [];
    ends = find( xx(1:(end-1),1) ~= xx(2:end,1) );
    if isempty(ends)
        if iscell
            b = cell( 1, m );
        else
            b = zeros( m, 1 );
        end
        return;
    end
    starts = [1; ends+1];
    ends(end+1) = size(xx,1);
    lengths = ends-starts+1;
    if iscell
        b = cell( 1, m );
        for i=1:length(starts)
            b{i} = xx( starts(i):ends(i), 2 );
        end
    else
        maxrow = max(starts-ends)+1;
        b = zeros( m, maxrow );
        for i=1:length(starts)
            ei = ends(i);
            si = starts(i);
            b( i, 1:(ei-si+1) ) = xx( si:ei, 2 );
        end
    end
end

    