function gp = getRealGrowth( m, ci )
%gp = getRealGrowth( m, ci )
%   This function computes the equivalent growth parameters from the
%   displacements of cell ci.
%   The result is a 6-element vector consisting of major growth, minor
%   growth, growth angle, major bend, minor bend, and bend angle.
%
%   NEVER USED, EXCEPT BY getAllRealGrowth, WHICH IS NEVER USED.

    J = getMeshCellFrame( m, ci );
    avStrain = sum( m.celldata(ci).displacementStrain, 2 )/6;
    avStrain = rotateTensor( avStrain, J' );
    [ major, minor, theta ] = growthParamsFromTensor( avStrain );
    avBendStrain = (m.celldata(ci).displacementStrain * [-1;-1;-1;1;1;1])/6;
    avBendStrain = rotateTensor( avBendStrain, J' );
    [ majorBend, minorBend, thetaBend ] = growthParamsFromTensor( avBendStrain );
    gp = [ major, minor, theta, majorBend, minorBend, thetaBend ];
end
