function [coeffs,dv] = meshVolumeChange( m, side, displacements )
%[coeffs,dv] = meshVolumeChange( m, side, displacements )
%   Calculate the change in enclosed volume of a foliate mesh (presumed to
%   enclose a central void) resulting from a given set of small
%   displacements of the specified side of the mesh. This is a linear
%   combination of the components of DISPLACEMENTS, whose coefficients are
%   returned in COEFFS as a row vector. DV is calculaated by:
%
%       dv = dot( coeffs, reshape( displacements', 1, [] ) );
%
%   DISPLACEMENTS can be omitted, in which case the DV result must also be
%   omitted.
%
%   The value of SIDE is 1 or 2.
%
%   See also: volumeChange

    if isVolumetricMesh( m )
        coeffs = [];
        dv = 0;
        return;
    end
    
    surfacenodes = m.prismnodes( side:2:size( m.prismnodes, 1 ), : );
    if (nargin < 3) || (nargout < 2)
        coeffs = volumeChange( surfacenodes, m.tricellvxs );
    else
        [coeffs,dv] = volumeChange( surfacenodes, m.tricellvxs, displacements );
    end
end
