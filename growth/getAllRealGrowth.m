function m = getAllRealGrowth( m )
%m = getAllRealGrowth( m )
%
%   NEVER USED.

    numcells = size(m.tricellvxs,1);
    m.realGrowth = zeros(numcells,6);
    
    for ci=1:numcells
        m.realGrowth(ci,1:6) = getRealGrowth( m, ci );
    end
end
