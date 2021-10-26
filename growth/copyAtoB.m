function m = copyAtoB( m )
%m = copyAtoB( m );
%   Copy the A morphogens to the B side.

    growthmgens = FindMorphogenRole( m, {'KAPAR','KAPER','KBPAR','KBPER'} );
    m.morphogens(:,growthmgens([3 4])) = m.morphogens(:,growthmgens([1 2]));
end
