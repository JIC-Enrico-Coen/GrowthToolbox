function f = combiningFunctionIndexed( method )
%f = combiningFunctionIndexed( method )
%   Return a minArray, maxArray, sumArray, or averageArray according to
%   the value of method.
%
%   See also: minArray, maxArray, sumArray, averageArray,
%       weightedAverageArray, combiningFunction.

    switch method
        case 'min'
            f = @minArray;
        case 'max'
            f = @maxArray;
        case 'sum'
            f = @sumArray;
        case 'wav'
            f = @weightedAverageArray;
        otherwise
            f = @averageArray;
    end
end
