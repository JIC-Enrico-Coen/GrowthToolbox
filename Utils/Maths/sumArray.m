function [a,n] = sumArray( indexes, values, shape )
%[a,n] = sumArray( indexes, values, shape )
%   Given an array VALUES and an array INDEXES of the same shape as VALUES
%   consisting of indexes into another array of shape SHAPE, construct an
%   array A of that shape such that A(I) = the sum of the elements of
%   VALUES for which the corresponding element of INDEXES is I.  N is a
%   list of the number of times each index occurred.
%
%   SHAPE defaults to a column vector whose length is the largest member of
%   INDEXES.
%
%   See also: minArray, maxArray, averageArray, weightedAverageArray.

    if (nargin < 3) || isempty(shape)
        shape = [ max(indexes(:)), 1 ];
    elseif length(shape)==1
        shape = [ shape, 1 ];
    end
    a = zeros( shape );
    n = zeros( shape );
    for i=1:numel(indexes)
        ii = indexes(i);
        if ii > 0
            a(ii) = a(ii) + values(i);
            n(ii) = n(ii) + 1;
        end
    end
end
