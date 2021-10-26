function m = meshZeroStrain( m )
%mesh = meshZeroStrain( mesh )    Set all residual strains to zero.

    numCells = length(m.celldata);
    for ci=1:numCells
        m.celldata(ci).eps0gauss = zeros( 6, 6 );
        m.celldata(ci).residualStrain = zeros( size(m.celldata(ci).residualStrain) );
    end
end
