function b = invertCellArray( a, n )
%b = invertCellArray( a, n )
%   A is a cell array of column vectors of positive integers.
%   The result B is a cell array of column vectors such that B{I} lists all
%   of the members of A that contain I, in increasing order.
%
%   The length of B will be the maximum value found in A, or if N is
%   supplied, then N if that is larger.

    if nargin >= 2
        numresult = n;
    else
        numresult = 0;
    end
    numitems = zeros( numel(a), 1 );
    for i=1:numel(a)
        numitems(i) = numel(a{i});
        numresult = max( numresult, max(a{i}) );
    end
    ba = [ reshape( cell2mat( a(:) ), [], 1 ), zeros( sum(numitems), 1 ) ];
    k = 0;
    for i=1:numel(a)
        ba( (k+1):(k+numitems(i)), 2 ) = i;
        k = k + numitems(i);
    end
    ba = sortrows( ba );
    [starts,ends] = runends( ba(:,1) );
    b = cell( numresult, 1 );
    for i=1:length(starts)
        s = starts(i);
        e = ends(i);
        b{ ba(s,1) } = ba(s:e,2);
    end
end
