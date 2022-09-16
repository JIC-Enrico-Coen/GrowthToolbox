function [ia,lengths] = invertArrayToCellArray( a, nv )
%[ia,lengths] = invertArray2( a, nv )
%   A is an N*K array. Its values are indexes into a dimension of another
%   array of length NV.
%
%   The result IA is a cell array of length NV of column vectors, listing
%   for each value in the range 1:NV the indexes of the rows of A
%   containing that value.
%
%   LENGTHS is an NV*1 arrays of the lengths of the members of IA.
%
%   If NV is omitted it is taken to be max(A(:)).

    if nargin < 2
        nv = max(a(:));
    end
    
    b = [ a(:), repmat( (1:size(a,1))', size(a,2), 1 ) ];
    c = sortrows( b );
    [starts,ends] = runends( c(:,1) );
    ia = cell( nv, 1 );
    lengths = zeros( nv, 1 );
    for i=1:length(starts)
        s = starts(i);
        e = ends(i);
        ia{ c(s,1) } = c(s:e,2);
        lengths( c(s,1) ) = e-s+1;
    end
end