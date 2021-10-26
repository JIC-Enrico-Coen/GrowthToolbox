function e = strainEnergy( strain, elasticity )
%e = strainEnergy( strain, elasticity )
%   Compute the energy resulting from the strain and elasticity.
%   Strain is a column 6-vector representing a 3*3 matrix, and elasticity is a 6*6
%   matrix.  The result is strain'*elasticity*strain.
    
    e = strain'*elasticity*strain;
end
