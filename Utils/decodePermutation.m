function pairs = decodePermutation( pairs )
%pairs = decodePermutation( pairs )
%   PAIRS is an N*(2+M) array of integers.  Every integer occurs exactly
%   twice in the first two columns, and the two occurrences are in
%   different rows.  Thus the set of pairs defines a cyclic ordering of the
%   set of integers.  PAIRS will be reordered so that the first two columns
%   represent that cyclic ordering.

% pairsInit = pairs
    numpairs = size(pairs,1);
    pairs(:,[1 2]) = pairs(:,[1 2])+1;
    ints = unique(pairs(:,[1 2]));
    reindex = zeros(1,max(ints));
    reindex(ints) = 1:length(ints);
% reindex
    pairs(:,[1 2]) = reshape( reindex(pairs(:,[1 2])), numpairs, 2 );
    
    pairindex = zeros( numpairs, 2 );
    for i=1:numpairs
        for j=pairs(i,[1 2])
            if pairindex(j,1)==0
                pairindex(j,1) = i;
            else
                pairindex(j,2) = i;
            end
        end
    end
% pairindex
% pairs
    

    curpair = 1;
    p = zeros(1,numpairs);
    p(1) = 1;
    nextp = pairs(curpair,2);
    for i=2:numpairs
        if curpair==pairindex(nextp,1)
            curpair = pairindex(nextp,2);
        else
            curpair = pairindex(nextp,1);
        end
        if nextp==pairs(curpair,2)
            pairs(curpair,[1 2]) = pairs(curpair,[2 1]);
        end
        nextp = pairs(curpair,2);
        p(i) = curpair;
    end
  % p

    pairs = pairs(p,:);
% pairsReordered = pairs
    pairs(:,[1 2]) = ints(pairs(:,[1 2]))-1;
% pairsRestoredNumbers = pairs
    if ints(1)==1
        z = find(pairs(:,1)==0);
        pairs = pairs( [ z:numpairs, 1:(z-1) ], :);
    end
% pairsCycled = pairs
end
