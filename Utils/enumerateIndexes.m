function ii = enumerateIndexes( sz )
%ii = enumerateIndexes( sz )
%   sz is a vector of N integers. The result is an array of N columns and
%   prod(sz) rows, enumerating all combinations of valid subscripts into an
%   array of size sz. The first subscript varies fastest. Thus subscripting
%   an array of the given size with the K'th row of indexes will give
%   element K of the array.
    
    if isempty(sz)
        ii = [];
        return;
    end

    ii = (1:sz(1))';
    for si = 2:numel(sz)
        ii = combineIndexes( ii, sz(si) );
    end
end

function kk = combineIndexes( jj, len )
    kk = [ repmat( jj, len, 1 ), reshape( repmat( 1:len, size(jj,1), 1 ), [], 1 ) ];
end
