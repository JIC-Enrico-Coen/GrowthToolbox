function amounts = leaf_total_morphogen( m, mgens )
    mgenindexes = FindMorphogenIndex2( m, mgens );
    validOfSelectedMgens = find( mgenindexes > 0 );
    amounts = zeros( size( mgenindexes ) );
    validMgenAbsIndexes = mgenindexes( validOfSelectedMgens );
    mgensPerVertex = m.morphogens( :, validMgenAbsIndexes );
    for vMIi=1:length(validMgenAbsIndexes)
        mgenRelIndex = validOfSelectedMgens( vMIi );
        mgenPerFE = perVertextoperFE( m, mgensPerVertex( :, mgenRelIndex ), m.mgen_interpType{ validMgenAbsIndexes(mgenRelIndex) } );
        totalMgen = sum( mgenPerFE .* m.cellareas );
        amounts( validOfSelectedMgens(vMIi ) ) = totalMgen;
    end
end
