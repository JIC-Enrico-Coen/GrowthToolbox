function m = makeZeroGrowthTensors( m )
%m = makeZeroGrowthTensors( m )
%   Set the growth tensors at every vertex of every cell to zero.

    numFEs = getNumberOfFEs( m );
    for ci=1:numFEs
        m.celldata(ci).Gglobal = zeros( 6, 6 );
        m.celldata(ci).Glocal = zeros( 6, 3 );
    end
end
