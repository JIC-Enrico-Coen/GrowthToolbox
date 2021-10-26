function [pol_mgen,pol_mgen2] = polariserIndex( m )
%[pol_mgen,pol_mgen2] = polariserIndex( m )
%   All meshes have at least one polariser. Volumetric meshes may have two,
%   but need not.

    pol_mgen = FindMorphogenRole( m, 'POLARISER' );
    if pol_mgen==0
        pol_mgen = FindMorphogenRole( m, 'POL' );
    end
    if nargout >= 2
        pol_mgen2 = FindMorphogenRole( m, 'POL2' );
    end
end
