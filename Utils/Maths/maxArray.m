function a = maxArray( indexes, values, shape )
%a = maxArray( indexes, values, shape )
%   Given an array VALUES and an array INDEXES of the same shape as VALUES
%   consisting of indexes into another array of shape SHAPE, construct an
%   array A of that shape such that A(I) = the maximum of the elements of
%   VALUES for which the corresponding element of INDEXES is I.
%
%   SHAPE defaults to a column vector whose length is the largest member of
%   INDEXES.
%
%   See also: sumArray, minArray, averageArray, weightedAverageArray.

    if (nargin < 3) || isempty(shape)
        shape = [ max(indexes(:)), 1 ];
    elseif length(shape)==1
        shape = [ shape, 1 ];
    end
    a = -inf( shape );
    for i=1:numel(indexes)
        ii = indexes(i);
        a(ii) = max( a(ii), values(i) );
    end
end
