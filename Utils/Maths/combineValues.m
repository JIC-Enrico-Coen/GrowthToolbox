function v = combineValues( vv, weights, method, dim )
%v = combineValues( vv, method, dim )
%v = combineValues( vv, weights, method, dim )
%   Find the minimum, maximum, sum, weighted sum, average, or weighted
%   average of an array along a given dimension.

    if nargin==3
        dim = method;
        method = weights;
    end
    switch method
        case 'min'
            v = min(vv, [], dim);
        case 'max'
            v = max(vv, [], dim);
        case 'sum'
            v = sum(vv, dim);
        case 'wsum'
            v = sum(vv.*weights, dim);
        case 'wav'
            v = sum(vv.*weights,dim)./sum(weights,dim);
        otherwise
            v = sum(vv,dim)/size(vv,dim);
    end
end

            