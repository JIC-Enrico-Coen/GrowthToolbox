function m = rescaleSpaceTime( m, spaceunitname, spacescale, timeunitname, timescale )
%m = rescaleSpaceTime( m, spaceunitname, spacescale, timeunitname, timescale )
%   Choose new units for space and time.  m is physically unchanged by
%   this, and therefore its growth behaviour should be unaltered.  We could
%   refrain from changing m at all, and merely store the factors that
%   convert between internal units and units displayed to the user.
%   However, it is useful to actually rescale m itself, as a check on the
%   invariance of our calculations to such rescaling.
%
%   The new space unit is SPACESCALE old units.  Therefore all of the
%   numbers that represent distances or positions must be divided by
%   SPACESCALE.  Areas must be divided by SPACESCALE^2.  Gradients must be
%   multiplied by SPACESCALE.
%
%   The new time unit is TIMESCALE old units.  Therefore every
%   numerical time must be divided by TIMESCALE.  Every rate of change must
%   be multiplied by TIMESCALE.  Every decay rate must be raised to the
%   power TIMESCALE.  Every growth rate g should in principle be replaced
%   by (1+g)^timescale - 1; when g is small, this is close to g*TIMESCALE.
%
%   Elasticity coefficients are scale-free.
%
%   Diffusion constants must be multiplied by timescale/spacescale^2.

    setGlobals();
    full3d = usesNewFEs( m );
    
    if ~isempty(spaceunitname)
        m.globalProps.distunitname = spaceunitname;
    end
    if ~isempty(timeunitname)
        m.globalProps.timeunitname = timeunitname;
    end

    if spacescale ~= 1
        areascale = spacescale*spacescale;
        volumescale = areascale*spacescale;
        m.displacements = m.displacements/spacescale;
        m.gradpolgrowth = m.gradpolgrowth * spacescale;
        m.cellareas = m.cellareas / areascale;
        if full3d
            m.FEsets(1).fevolumes = m.FEsets(1).fevolumes / volumescale;
            m.FEnodes = m.FEnodes/spacescale;
        else
            m.nodes = m.nodes/spacescale;
            m.prismnodes = m.prismnodes/spacescale;
        end
        m.globalProps.thresholdsq = m.globalProps.thresholdsq / areascale;
        m.globalDynamicProps.cellscale = m.globalDynamicProps.cellscale / spacescale;
        m.globalDynamicProps.thicknessAbsolute = m.globalDynamicProps.thicknessAbsolute / spacescale;
        m.globalDynamicProps.currentArea = m.globalDynamicProps.currentArea / areascale;
        m.globalDynamicProps.previousArea = m.globalDynamicProps.previousArea / areascale;
        m.globalDynamicProps.currentVolume = m.globalDynamicProps.currentVolume / volumescale;
        m.globalDynamicProps.previousVolume = m.globalDynamicProps.previousVolume / volumescale;
        m.globalProps.initialArea = m.globalProps.initialArea / areascale;
        m.globalProps.initialVolume = m.globalProps.initialVolume / volumescale;
        m.globalProps.bendunitlength = m.globalProps.bendunitlength / areascale;
        m.plotdefaults.axisRange = m.plotdefaults.axisRange / spacescale;
        m.plotdefaults.clippingDistance = m.plotdefaults.clippingDistance / spacescale;
        m = calcCloneVxCoords( m );

        m.secondlayer.splitThreshold = m.secondlayer.splitThreshold/spacescale;
        m.secondlayer.cellarea = m.secondlayer.cellarea/areascale;
        m.secondlayer.celltargetarea = m.secondlayer.celltargetarea/areascale;
        m.secondlayer.averagetargetarea = m.secondlayer.averagetargetarea/areascale;
        if isfield( m.secondlayer, 'vvlayer' ) && ~isempty( m.secondlayer.vvlayer )
            m.secondlayer.vvlayer.mainvxs = m.secondlayer.vvlayer.mainvxs / spacescale;
            m.secondlayer.vvlayer.vvptsC = m.secondlayer.vvlayer.vvptsC / spacescale;
            m.secondlayer.vvlayer.vvptsW = m.secondlayer.vvlayer.vvptsW / spacescale;
            m.secondlayer.vvlayer.vvptsM = m.secondlayer.vvlayer.vvptsM / spacescale;
            m.secondlayer.vvlayer.vxLengthsMM = m.secondlayer.vvlayer.vxLengthsMM / spacescale;
            m.secondlayer.vvlayer.vxLengthsM = m.secondlayer.vvlayer.vxLengthsM / spacescale;
            m.secondlayer.vvlayer.vxLengthsW = m.secondlayer.vvlayer.vxLengthsW / spacescale;
            m.secondlayer.vvlayer.vvpts = m.secondlayer.vvlayer.vvpts / spacescale;
            % cellpolarity: [132x3 double]
            % diffusion: [3x5 double]
        end
    end
    
    if timescale ~= 1
        m.globalProps.timestep = m.globalProps.timestep/timescale;
        m.globalDynamicProps.currenttime = m.globalDynamicProps.currenttime/timescale;
        m.mgen_production = m.mgen_production * timescale;
        m.mgen_absorption = m.mgen_absorption * timescale;
        STRAINRET_MGEN = FindMorphogenRole( m, 'STRAINRET' );
        m.morphogens(:,STRAINRET_MGEN) = ...
            m.morphogens(:,STRAINRET_MGEN) .^ timescale;
    end
    
    Kscale = timescale/(spacescale*spacescale);
    if Kscale ~= 1
        for i=1:length(m.conductivity)
            m.conductivity(i).Dpar = m.conductivity(i).Dpar * Kscale;
            m.conductivity(i).Dper = m.conductivity(i).Dper * Kscale;
        end
    end
end
