function [splitIndex,meanvalue,minvar,shiftvalues] = splitCircularValues( values, weights, period )
% [splitIndex,meanvalue,minvar,shiftvalues] = splitCircularValues( values, weights, period )
%   VALUES are assumed to already lie in the interval [ 0, PERIOD ), and to
%   be sorted. The split point is chosen to minimise the variance of the
%   unrolled distribution.
%
%   SPLITINDEX will be the elements of the VALUES that would be first in
%   the shifted array.
%
%   MEANVALUE is the mean of the shifted distribution, put into the range
%   [0,PERIOD].
%
%   MINVAR is the minimum variance achieved.
%
%   SHIFTVALUES is the result of shifting the VALUES array to make the
%   SPLITINDEX element first, adding PERIOD to all the elements that were
%   before SPLITINDEX, and subtracting the first value from all the values.
%   SHIFTVALUES has the same shape as VALUES.
%
% [splitIndex,meanvalue,minvar,shiftvalues] = splitCircularValues( values, period )
%
%   As above with all data points weighted equally.
%
%   The brute force method of calculating the variance for every cyclic
%   shift of the data takes quadratic time. We use a linear algorithm to
%   obtain the same results.

    
%     % Brute-force method. Quadratic time.
%     % This code is included to allow for testing. The linear algorithm
%     % should calculate the same variances, up to rounding error.
%
%     tic
%     numvalues = length(values);
%     variances = zeros( 1, numvalues );
%     xvalues = [ values, values+period ];
%     for xi=1:numvalues
%         variances(xi) = var( xvalues( xi:(xi+numvalues-1) ), 1 );
%     end
%     [~, splitIndex1] = min( variances );
%     toc

    if isempty(values)
        splitIndex = [];
        meanvalue = NaN;
        minvar = NaN;
        shiftvalues = [];
        return;
    end
        
    sz_values = size(values);
    values = values(:);
    if nargin==2
        period = weights;
        weights = ones(size(values));
    else
        weights = weights(:);
    end

    totalweight = sum( weights );
    
    % By a right shift of the data we mean adding PERIOD to some initial
    % segment of VALUES. (We can imagine them, and their corresponding
    % weights, being moved to the ends of their respective arrays, but no
    % such movement of the data is required.) We want to calculate the
    % variance of every right shift of the data, and find the shift that
    % minimises it.
    
    m1 = sum(values .* weights)/totalweight;
    delta_means = [ 0; weights(1:(end-1))*(period/totalweight) ];
    cumsum_delta_means = cumsum( delta_means ); % (0:(numvalues-1))*(period/numvalues);
    means = m1 + cumsum_delta_means;
    % means is the set of means of all right shifts of the data.

    v1 = sum((values.^2) .* weights)/totalweight;
    delta_vars0 = ((2*period*values + period^2) .* weights)/totalweight;
    cumsum_delta_vars0 = [0; cumsum( delta_vars0(1:(end-1)) ) ];
    vars0 = v1 + cumsum_delta_vars0;
    % vars0 is the set of moments about zero of all right shifts of the data.
    
    vars1 = vars0 - means.^2;
    % vars1 is the set of variances of all right shifts of the data.
    
    [minvar, splitIndex] = min( vars1 );
    
    meanvalue = mod( means(splitIndex), period );
    
    startval = values(splitIndex);
    if nargout >= 4
        shiftvalues = reshape( [ values( splitIndex:end )-startval; values( 1:(splitIndex-1) )+period-startval ], sz_values );
    end
    
%     splitIndexes = [ splitIndex1 splitIndex ]
end
