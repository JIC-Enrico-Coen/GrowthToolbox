function e = totalStrainEnergy( m )
%e = totalStrainEnergy( m )
%   Compute the total strain energy due to the residual strains in the mesh m.
%   NEVER USED.
    
    thickness = m.prismnodes(2:2:end,:) - m.prismnodes(1:2:end,:);
    thickness = sqrt( sum( thickness.*thickness, 2 ) );
    cellthickness = sum( thickness( m.tricellvxs ), 2 )/3;
    numcells = length(m.celldata);
    averageStrainRate = (m.outputs.residualstrain.A + m.outputs.residualstrain.B)/2;
  % averageStrain = permute( sum( reshape([m.celldata.residualStrain],6,6,[]), 2 )/6, [3 1 2] );
    energydensityrate = sum( (averageStrainRate * m.globalProps.D) .* averageStrainRate, 2 );
    e = sum( energydensityrate.*m.cellareas.*cellthickness ) * (m.globalProps.timestep^2);
end
