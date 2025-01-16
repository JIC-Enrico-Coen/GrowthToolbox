function [data,infval] = reduceInfToFinite( data, inf_factor, nan_value )
%[data,infval] = reduceInfToFinite( data, inf_factor, nan_value )
% Eliminate non-finite values from data.
%
% NaN is replaced by nan_value. (Supply NaN to leave NaNs unchanged.)
%
% +/- Inf is replaced by +/- a factor times the largest absolute finite
% value present. Pass Inf to leave +/- Infs unchanged.

    data(isnan(data)) = nan_value;

    % Treat +/- Inf as +/- a factor times the largest absolute finite
    % value present.
    if any(isinf(data(:)))
        finitedata = data(~isinf(data));
        maxAbsFiniteData = max(abs(finitedata));
%         nominalInfValue1 = ceil( inf_factor * maxAbsFiniteData );
        nominalInfValue = inf_factor * maxAbsFiniteData;
        data(isinf(data)) = nominalInfValue * sign( data(isinf(data)) );
    end
    
    infval = max(data(:));
end
