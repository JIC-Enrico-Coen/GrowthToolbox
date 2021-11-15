function m = makeedgethreshsq( m, method )
    if nargin < 2
        method = 'orig';
    end
    switch method
        case 'orig'
            m.globalProps.thresholdsq = max(edgelengthsqs(m)) * 2;
        case 'orig1'
            m.globalProps.thresholdsq = max(edgelengthsqs(m));
        case 'mean'
            m.globalProps.thresholdsq = mean(edgelengthsqs(m)) * 2;
        case 'mean1'
            m.globalProps.thresholdsq = mean(edgelengthsqs(m));
    end
end
