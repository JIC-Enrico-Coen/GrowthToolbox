function [m,ok] = setSmgenFromImgen( m, idmgen, smgen, production, diffusion, absorption )
%[m,ok] = setSmgenFromImgen( m, idmgen, smgen, production, diffusion, absorption )
%   Given an identity morphogen idmgen and a signalling morphogen smgen,
%   set the signalling morphogen to be equal to the identity morphogen, and
%   to have the given diffusion and absorption coefficients.  If production
%   is positive, then the signalling morphogen will be produced at that
%   rate where the identity morphogen is present.  Otherwise, it will not
%   be produced, but clamped to 1 in that region.
%
%   The morphogens must exist and be different.  If not, m is not changed
%   and ok is false.
%
%   The identity morphogen should take the values 0 or 1 everywhere.
%
%   The effect of diffusion and absorption from a source of fixed value is
%   that the stable state will have a characteristic distance from the
%   source of the order of sqrt(diffusion/absorption).

    mgenIndexes = FindMorphogenIndex( m, { idmgen, smgen } );
    ok = (length(mgenIndexes) == 2) && (mgenIndexes(1) ~= mgenIndexes(2));
    if ~ok
        return;
    end
    idmgen = mgenIndexes(1);
    smgen = mgenIndexes(2);
    m = leaf_mgen_absorption( m, smgen, absorption );
    m = leaf_mgen_conductivity( m, smgen, diffusion );
    if production > 0
        m.morphogenclamp( :, smgen ) = 0;
        m.mgen_production( :, smgen ) = production .* m.morphogens(:,idmgen);
    else
        m.morphogenclamp( :, smgen ) = m.morphogens(:,idmgen);
        m.morphogens(:,smgen) = m.morphogens(:,idmgen);
    end
end
