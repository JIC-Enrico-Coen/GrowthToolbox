function f = combiningFunction( method, dim )
%f = combiningFunction( method, dim )
%   Return a function that finds the minimum, maximum, sum, average, or
%   weighted average of an array along a specified dimension.
%
%   method is 'min' for minimum, 'max' for maximum, 'sum' for sum, 'mid'
%   or 'ave' for average, or 'wav' for weighted average.
%
%   See also: combiningFunctionIndexed.

    switch method
        case 'min'
            f = @(v) min( v, [], dim );
        case 'max'
            f = @(v) max( v, [], dim );
        case 'sum'
            f = @(v) sum( v, dim );
        case 'wav'
            f = @(v,w) sum( v.*w, dim )./sum(w,dim);
        otherwise
            % Average.
            f = @(v) sum( v, dim )/size( v, dim );
    end
end
