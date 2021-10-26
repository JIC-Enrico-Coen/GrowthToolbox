function m = makeedgethreshsq( m )
    m.globalProps.thresholdsq = max(edgelengthsqs(m)) * 2;
end
