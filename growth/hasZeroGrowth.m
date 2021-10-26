function z = hasZeroGrowth( m )
    if isVolumetricMesh( m )
        growthmgens = FindMorphogenRole( m, 'KPAR','KPAR2','KPER', false );
        if growthmgens(3)==0
            growthmgens(3) = growthmgens(2);
        end
    else
        growthmgens = FindMorphogenRole( m, 'KAPAR', 'KAPER', 'KBPAR', 'KBPER', 'KNOR' );
    end
    
    growthmgens = growthmgens(growthmgens > 0);
    z = all(all(m.morphogens( :, growthmgens )==0));
end
