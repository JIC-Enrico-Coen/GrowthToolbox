function [m,ok,splitdata] = onestep( m, useGrowthTensors, useMorphogens )
%[m,ok] = onestep( m, useGrowthTensors )
%   Run one step of the iteration:
%   * Calculate the polarisation gradients.
%   * Perform a FEM calculation for growth.
%   * Restore flatness/thickness.
%   * Perform dilution-by-growth.
%   * Generate the FEM cell normal vectors.
%   * Split large FEM cells.
%   * Recalculate FEM cell areas.
%   * Recalculate the second layer global positions and split large
%     second layer cells.
%   The result OK will be false if the user interrupts in the middle of a
%   simulation step or there is an error in the interaction function.

    ok = true;
    splitdata = [];
    if m.stop
        ok = false;
        return;
    end
    if nargin < 2, useGrowthTensors = false; end
    if nargin < 3, useMorphogens = ~useGrowthTensors; end
    full3d = usesNewFEs( m );
    isvolumetric = isVolumetricMesh( m );
    m.globalDynamicProps.previousArea = m.globalDynamicProps.currentArea;
    m.globalDynamicProps.previousVolume = m.globalDynamicProps.currentVolume;
    if m.globalProps.flatten
        m = meshFlatStrain( m, m.globalProps.flattenratio );
    end
    
    moved = false;
    growthByFE = false;
    if m.globalProps.growthEnabled
        if useGrowthTensors
            if any( reshape( [ m.celldata.cellThermExpGlobalTensor ], 1, [] ) ~= 0 ) || any( reshape( [ m.directGrowthTensors ], 1, [] ) ~= 0 )
                growthByFE = true;
            else
                useGrowthTensors = false;
            end
            if any( reshape( [ m.celldata.residualStrain ], 1, [] ) ~= 0 )
                growthByFE = true;
            end
        elseif m.globalProps.flatten
            growthByFE = true;
        elseif m.globalProps.selfGrowth
            growthByFE = false;
            [m,result] = invokeIFcallback( m, 'Selfgrowth' );
            moved = result.didGrow;
            if moved
                m.displacements = result.displacements;
            end
            if any(~isfinite(m.displacements(:)))
                xxxx = 1;
            end
        elseif useMorphogens
            if any( any( m.morphogens(:,1:3) ~= 0 ) )
                growthByFE = true;
            end
            STRAINRET_MGEN = FindMorphogenRole( m, 'STRAINRET', false );
            if STRAINRET_MGEN==0
                useResidStrain = false;
            elseif all( m.morphogens( :, STRAINRET_MGEN ) == 0 )
                useResidStrain = false;
            elseif all( reshape( [ m.celldata.residualStrain ], 1, [] ) == 0 )
                useResidStrain = false;
            else
                useResidStrain = true;
            end
            if useResidStrain
                growthByFE = true;
            end
            
            if any( reshape( [ m.celldata.residualStrain ], 1, [] ) ~= 0 )
                growthByFE = true;
            end
        end
    end
    
    if growthByFE
        timedFprintf( 1, 'Growth computation beginning for iteration %d (time %g - %g).\n', ...
            m.globalDynamicProps.currentIter + 1, m.globalDynamicProps.currenttime, m.globalDynamicProps.currenttime + m.globalProps.timestep );
    else
        timedFprintf( 1, 'No growth or residual strain for iteration %d (time %g - %g).\n', ...
            m.globalDynamicProps.currentIter + 1, m.globalDynamicProps.currenttime, m.globalDynamicProps.currenttime + m.globalProps.timestep );
    end
    
    if growthByFE
%         oldprismnodes = m.prismnodes;
        transportspeed = cell( size( m.transportfield ) );
        for i=1:length(transportspeed)
            tv = transportvectors( m, i );
            if ~isempty( tv )
                transportspeed{i} = sqrt(sum(tv.^2,2));
            end
        end
        THICKNESSMGENINDEX = FindMorphogenRole( m, 'KNOR' );
        if THICKNESSMGENINDEX == 0
            thicknessmgen = [];
        else
            thicknessmgen = getEffectiveMgenLevels( m, THICKNESSMGENINDEX );
            switch m.globalProps.thicknessMode
                case { 'direct', 'specified' }
                    oldthicknesses = getThickness( m );
                    thicknessmgen = getEffectiveMgenLevels( m, m.mgenNameToIndex.KNOR );
                    KNOR_thicknesses = oldthicknesses .* ...
                        (1 + thicknessmgen * m.globalProps.timestep);
            end
        end
        
        if m.globalProps.plasticGrowth
            [m,u,G] = growthDisplacements( m );
            u = reshape( [ u, u ]', 3, [] )';
            m.effectiveGrowthTensor = G;
        else
            if full3d
                [m,u] = totalKFE( m, useGrowthTensors, useMorphogens );
            else
                [m,u] = totalK( m, useGrowthTensors, useMorphogens );
            end
            ok = ~isempty(u);
            timedFprintf( 1, 'Allocating m.effectiveGrowthTensor.\n' );

            m.effectiveGrowthTensor = zeros( getNumberOfFEs(m), ...
                                             size(m.effectiveGrowthTensor,2) );
            timedFprintf( 1, 'Allocated m.effectiveGrowthTensor.\n' );
        end
        % If the computation failed, u may have been returned as empty.
        
        % Determine whether the mesh moved.  Normally this will be because
        % some displacement u is nonzero.  The other case is for an
        % old-style mesh for which growth in thickness is being specified
        % directly by KNOR instead of by the physics.
        moved = any(u(:)) && ~isempty(u) && ~m.stop;
        if (~moved) && (~isvolumetric) && ~isempty(u)
            moved = strcmp( m.globalProps.thicknessMode, 'direct' ) ...
                    && any(thicknessmgen);
        end
        
        if moved
            if full3d
                m.FEnodes = m.FEnodes + u;
            else
                m.prismnodes = m.prismnodes + u;
            end
            if ~isvolumetric
                switch m.globalProps.thicknessMode
                    case { 'direct', 'specified' }
                        % KNOR is interpreted as directly prescribing the
                        % growth in thickness.  Here the thickness is set to
                        % the prescribed amount.
                        [m,displacements] = setThickness( m, KNOR_thicknesses );
                        u = u + displacements;
                    case 'scaled'
                        % Thickness is defined as always being in proportion to
                        % a power of the area of the mesh.  Here it is set
                        % everywhere to that value.
                        [m,u] = restorethickness( m, u );
                    otherwise %  { 'actual', 'physical' }
                        % Growth in the normal direction is as calculated by
                        % the elasticity computation.  No correction required.
                end
                m.globalProps.trinodesvalid = 0;
                m = makeTRIvalid( m );
                if m.globalProps.alwaysFlat
                    [m,u] = restoreflatness( m, u );
                else
                    m = makeAreasAndNormals( m );
                    if m.globalProps.rectifyverticals
                        m = rectifyVerticals( m );
                    end
                    m = makebendangles( m );
                end
            end
            
            % Rescale transport vectors.
            for i=1:length(transportspeed)
                if ~isempty( tv )
                    newtv = transportvectors( m, mi );
                    newtransportspeed = sqrt(sum(newtv.^2,2));
                    nonzeros = transportspeed{i} > 0;
                    scaling = ones(length(transportspeed{i}),1);
                    scaling(nonzeros) = newtransportspeed(nonzeros)./transportspeed{i}(nonzeros);
                    m.transportfield{i} = m.transportfield{i} .* repmat( scaling, 1, 3 );
                end
            end
            
            if ~m.globalProps.flatten
                m = dilateSubstances( m, u );
            end
            clear u
            
        end
    end
    
    if moved
        m = calcCloneVxCoords( m );
        if isfield( m, 'volcells' ) && ~isempty( m.volcells )
            m.volcells.vxs3d = baryToGlobalCoords( m.volcells.vxfe, m.volcells.vxbc, m.FEnodes, m.FEsets.fevxs );
        end
        m = calcmeshareas( m );        
        m = VV_recomputeCoords( m );
        numflippededges = 0;
        numElided = 0;
        if ~m.globalProps.flatten
            if m.globalProps.allowFlipEdges
                [m,numflippededges] = flipedges( m );
            end
            if m.globalProps.allowElideEdges
                [m,numElided] = tryElideEdge( m );
            end
            [ m, ~, splitdata ] = trysplit( m );
            if hasNonemptySecondLayer( m )
                m.secondlayer = calcBioACellAreas( m.secondlayer );
                if m.globalProps.allowSplitBio
                    m = splitSecondLayer( m );
                end
                if m.secondlayer.jiggleAmount * m.secondlayer.splitThreshold ~= 0
                    m = perturbSecondLayer( m, ...
                            m.secondlayer.jiggleAmount * m.secondlayer.splitThreshold );
                end
                if strcmp( m.globalProps.biocolormode, 'area' )
                    m = setSecondLayerColorsByArea( m );
                end
            end
            if (numflippededges > 0) || (numElided > 0) || ~isempty( splitdata )
                if isfield( m, 'volcells' ) && ~isempty( m.volcells )
                    % Brute force recomputation of the relative locations of
                    % the volcells vertexes
                    newvxfe = zeros( size( m.volcells.vxfe ), 'uint32' );
                    newvxbc = zeros( size( m.volcells.vxbc ) );
                    bcerr = nan( length( m.volcells.vxfe ), 1 );
                    abserr = nan( length( m.volcells.vxfe ), 1 );
                    for pi=1:size(m.volcells.vxs3d,1)
                        [ newvxfe(pi), newvxbc(pi,:), bcerr(pi), abserr(pi) ] = findFE( m, m.volcells.vxs3d(pi,:), 'hint', m.volcells.vxfe(pi) );
                    end
                    m.volcells.vxfe = uint32( newvxfe );
                    m.volcells.vxbc = newvxbc;
                    xxxx = 1;
                end
            end
        end
    end
    
    if ~moved
        m.displacements = [];
    end
    
    timedFprintf( 1, 'Calculating polgrad.\n' );
    m = calcPolGrad( m );
  % maxgrad2 = max(abs(m.gradpolgrowth(:,1)))

    if m.globalProps.growthEnabled && (m.globalProps.boingNeeded == 1)
        m.globalProps.boingNeeded = 2;
    end
    m.saved = 0;
    if m.stop
        ok = false;
    end
    timedFprintf( 1, 'Completed.\n' );
end
    
