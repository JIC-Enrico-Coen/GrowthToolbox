function [a,n] = weightedAverageArray( indexes, values, weights, shape )
%[a,n] = weightedAverageArray( indexes, values, weights, shape )
%   Given an array VALUES, an array INDEXES of the same shape as VALUES
%   consisting of indexes into another array of shape SHAPE, , and an array
%   of weights of shape SHAPE, construct an array A of the shape such that
%   A(I) = the weighted average of the elements of VALUES for which the
%   corresponding element of INDEXES is I.  N is a list of the total weight
%   each index occurred with.
%
%   SHAPE defaults to a column vector whose length is the largest member of
%   INDEXES.
%
%   See also: sumArray, minArray, maxArray, averageArray.

    if (nargin < 4) || isempty(shape)
        shape = [ max(indexes(:)), 1 ];
    elseif length(shape)==1
        shape = [ shape, 1 ];
    end
    a = zeros( shape );
    n = zeros(shape,'int32');
    for i=1:numel(indexes)
        ii = indexes(i);
        a(ii) = a(ii) + values(i)*weights(i);
        n(ii) = n(ii) + weights(i);
    end
    nz = n ~= 0;
    a(nz) = a(nz)./double(n(nz));
end
