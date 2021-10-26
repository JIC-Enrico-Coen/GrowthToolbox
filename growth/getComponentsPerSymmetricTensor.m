function c = getComponentsPerSymmetricTensor( d )
%c = getComponentsPerSymmetricTensor( d )
%   Because "getComponentsPerSymmetricTensor" is clearer than "6".

    if nargin < 1
        d = 3;
    end
    c = (d*(d+1))/2;
end
