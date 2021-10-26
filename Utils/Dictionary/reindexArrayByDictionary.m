function a = reindexArrayByDictionary( reindex, a, dflt )
%a = reindexArrayByDictionary( reindex, a )
%   Use the reindexing data from a call of reindexDictionary to transform
%   the array a.  a must be either 1 or 2 dimensions, and in the latter
%   case it is assumed that it is the second dimension that must be
%   reindexed.

    if isempty(reindex)
        return;
    end
    if nargin < 3
        dflt = 0;
    end
    switch length(size(a))
        case 1
            if iscell(a)
                a(permMgens) = [ a(retainedMgens); cell( numExtraMgens, size(a,1) ) ];
            else
                a(reindex.perm) = [ a(reindex.retained); repmat( dflt, reindex.numextra, 1 ) ];
            end
            if reindex.numnew < reindex.numold
                a(reindex.deleted) = [];
            end
        case 2
            if iscell(a)
                a(:,reindex.perm) = [ a(:,reindex.retained), cell( size(a,1), reindex.numextra ) ];
            else
                a(:,reindex.perm) = [ a(:,reindex.retained), repmat( dflt, size(a,1)/size(dflt,1), reindex.numextra ) ];
            end
            if reindex.numnew < reindex.numold
                a(:,reindex.deleted) = [];
            end
    end
end
