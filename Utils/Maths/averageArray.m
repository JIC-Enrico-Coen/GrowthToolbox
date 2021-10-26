function [a,n] = averageArray( indexes, values, shape )
%[a,n] = averageArray( indexes, values, shape )
%   Given an array VALUES and an array INDEXES of the same shape as VALUES
%   consisting of indexes into another array of shape SHAPE, construct an
%   array A of the shape such that A(I) = the average of the elements of
%   VALUES for which the corresponding element of INDEXES is I.  N is a
%   list of the number of times each index occurred.
%
%   SHAPE defaults to a column vector whose length is the largest member of
%   INDEXES.
%
%   See also: sumArray, minArray, maxArray, weightedAverageArray.

    if (nargin < 3) || isempty(shape)
        shape = [ max(indexes(:)), 1 ];
    elseif length(shape)==1
        shape = [ shape, 1 ];
    end
    a = zeros( shape );
    n = zeros(shape,'int32');
    for i=1:numel(indexes)
        ii = indexes(i);
        a(ii) = a(ii) + values(i);
        n(ii) = n(ii) + 1;
    end
    nz = n ~= 0;
    a(nz) = a(nz)./double(n(nz));
end
