function m = setElasticity( m, bulkmodulus, poissonsRatio )
% UNUSED
    if (nargin>1) && (bulkmodulus >= 0)
        m.globalProps.bulkmodulus = bulkmodulus;
    end
    if (nargin>2) && (poissonsRatio >= 0)
        m.globalProps.poissonsRatio = poissonsRatio;
    end
    m = updateElasticity( m );
end
