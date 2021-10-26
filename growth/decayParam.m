function d = decayParam( T, T1 )
    r = T1/T;
    q = (1-r)./(1+r);
    d = -log10(q)./T1;
end
