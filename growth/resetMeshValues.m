function m = resetMeshValues( m )
%m = resetMeshValues( m )
%   This procedure:
%
%   sets all morphogens to zero
%   sets all clamping to zero
%   sets all production and absorption rates to zero
%   sets all diffusion constants to zero
%   sets all mutant and switch levels to 1
%   sets all dilution-by-growth and transportability flags to false
%   sets all plot priorities to 0
%   sets all plot thresholds to 0
%   sets the gradient of polariser to 0.
%   unfreezes all frozen polariser gradients
%   sets m.effectiveGrowthTensor to 0
%   turns off all fixed degrees of freedom of the vertexes
%   deletes all streamlines/microtubules
%
%   It is useful to call this in an interaction function in the initial
%   state, to clear out any crud that may have been saved to the initial
%   state file, giving your own code a clean slate on which to set the
%   properties you want.  A call of this is generated in new interaction
%   functions, in the first of the user code sections, so that you can
%   choose whether to retain it or not.

    m.morphogens(:) = 0;
    m.morphogenclamp(:) = 0;
    m.mgen_production(:) = 0;
    m.mgen_absorption(:) = 0;
    m.conductivity = emptystructarray( [1,getNumberOfMorphogens(m)], 'Dpar', 'Dper' );
    m.mutantLevel(:) = 1;
    m.mgenswitch(:) = 1;
    m.mgen_dilution(:) = false;
    m.mgen_transportable(:) = false;
    m.mgen_plotpriority(:) = 0;
    m.mgen_plotthreshold(:) = 0;
    m.gradpolgrowth(:) = 0;
    m.polfreeze(:) = 0;
    if isfield( m, 'polfreezebc' )
        m.polfreezebc(:) = 0;
    end
    m.polfrozen(:) = false;
    m.polsetfrozen(:) = false;
    m.effectiveGrowthTensor(:) = 0;
    m.fixedDFmap(:) = false;
    m.tubules = initTubules();
end
