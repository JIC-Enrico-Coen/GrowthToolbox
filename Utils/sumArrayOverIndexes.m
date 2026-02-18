function s = sumArrayOverIndexes( indexes, a, maxindex )
%s = sumOverIndexes( indexes, a, maxindex )
%   INDEXES is an array of positive integers the same size as A.
%   MAXINDEX is the maximum possible index (and might be greater than all
%   members of INDEXES). It defaults to max(INDEXES).
%
%   The result is an array of size MAXINDEX x 1 in which the i'th element
%   is the sum of all the elements of A that are assigned that index.
%
%   If INDEXES contained no repeated values, this would be equivalent to
%   S = A(INDEXES).

    if isempty(indexes)
        s = [];
        return;
    end
    if nargin < 3
        maxindex = max(indexes(:));
    end
    tic
    s = zeros( maxindex, 1 );
    for ii=1:numel(a)
        index = indexes(ii);
        s(index) = s(index) + a(ii);
    end
    toc
end
