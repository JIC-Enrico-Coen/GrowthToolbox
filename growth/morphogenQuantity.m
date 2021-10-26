function amount = morphogenQuantity( m, morphogens )
    if nargin < 2
        mgenIndexes = 1:getNumberOfMorphogens(m);
    else
        mgenIndexes = FindMorphogenIndex( m, morphogens );
    end
    vxsperFE = getNumVxsPerFE( m );
    fevols = repmat( feVolumes( m ), 1, vxsperFE );
    full3d = usesNewFEs(m);
    amount = zeros( 1, length(mgenIndexes) );
    for i=1:length(mgenIndexes)
        mi = mgenIndexes(i);
        if full3d
            amount(i) = sum( m.morphogens( m.FEsets(1).fevxs, mi ) .* fevols(:) );
        else
            amount(i) = sum( m.morphogens( m.tricellvxs, mi ) .* fevols(:) );
        end
    end
end
