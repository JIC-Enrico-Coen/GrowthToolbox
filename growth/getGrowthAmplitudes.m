function ga = getGrowthAmplitudes( m )

    numcells = size( m.tricellvxs, 1 );
    ga = zeros( numcells, 6 );
    for ci=1:numcells
        G = makeMeshLocalGrowthTensor( m, ci );
        a = sum( G(1:3,:), 1 )/6;
        b = sum( G(4:6,:), 1 )/6;
        ga(ci,:) = [ a+b, b-a ];
    end
    ga = ga * m.globalProps.timestep;
end
