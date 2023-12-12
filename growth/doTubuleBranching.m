function m = doTubuleBranching( m, dt )
%m = doTubuleBranching( m, dt )
%   Randomly create microtubules branching off existing microtubules during
%   a small time interval dt. There are three mutually exclusive methods of
%   specifying branching rates.
%
%   1. There may be a global rate of making new branches per unit time.
%   This is specified  by m.tubules.tubuleparams.prob_branch_time.
%   OBSOLETE, NO LONGER IMPLEMENTED.
%
%   2. There may be a global rate per microtubule per unit time.
%   This is specified  by m.tubules.tubuleparams.prob_branch_tubule_time.
%
%   3. There may be a global rate per unit length of tubule per unit time.
%   This is specified  by m.tubules.tubuleparams.prob_branch_length_time.
%
%   The first of these parameters that is nonzero, in the order listed
%   above, is the one that will be acted on.
%
%   Regardless of the mechanism for deciding how many to create, the
%   positions of their creation will be distributed over the microtubule
%   segments in proportion to the likelihood there.
%
%   The calculation also finds the creation time of each microtubule, but
%   this information is not currently used. It could be stored in each mt
%   anGFtd used to calculate the length of its first step.

    % Detect cases where there is nothing to be done.
    numtubules = length( m.tubules.tracks );
    if numtubules==0
        return;
    end
    
    if ~getModelOption( m, 'branch_by_length' )
        % When branch_by_length is true, I use a new, different, and
        % simpler method of generating the new tubules, which is the one
        % implemented by doTubuleBranching().
        % When it is false, I use the old method, which is implemented by
        % doTubuleBranchingOLD().
        m = doTubuleBranchingOLD( m, dt );
        return;
    end
    
    if isMorphogen( m, m.tubules.tubuleparams.prob_branch_scaling )
        branchScalingPerVertex = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_scaling' ) );
        if length(unique(branchScalingPerVertex))==1
            branchScalingPerVertex = branchScalingPerVertex(1);
        end
    else
        branchScalingPerVertex = 1;
    end
    branchScalingPerVertex = branchScalingPerVertex * m.tubules.tubuleparams.density_branch_scaling;
    xxxx = 1;
    doBranchScaling = (numel(branchScalingPerVertex) > 1) || (branchScalingPerVertex(1) ~= 1);
    
    branchPerVertex = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_length_time' ) ) .* branchScalingPerVertex;
    branchPerCurvature = leaf_getTubuleParamsPerVertex( m, 'prob_branch_length_curvature_time' ) .* branchScalingPerVertex;
    
    if all( branchPerVertex == 0 ) && all( branchPerCurvature == 0 )
        numfreebranches = 0;
        freeBlocalsegindexes = [];
        freeBranchSegbc = [];
        freeBranchTimes = [];
        freeBranchTubules = [];
    else
        % Decide where along the current MT new MTs will be spawned, and
        % on which side. Since we already know how many will be spawned,
        % their spawning points are uniformly distributed along the length
        % of the current MT. We do not take the trouble to ensure that two
        % MTs are not spawned at overlapping positions, nor do we handle
        % what happens if the spawning point should be across the edge of a
        % finite element and into a neighbouring element. This code is
        % therefore only valid if the mt diameter is small compared to
        % element size and the expected distance between spawning points.
        % We also do not test to see if there is an existing MT where the
        % new one is to be created. With MTs tending to grow in bundles,
        % this might be an important omission. Perhaps
        % leaf_createStreamlines should make this check.

        % Count the number of segments in all microtubules.
        totalsegments = length( [m.tubules.tracks.segmentlengths] );

        % Find the branching probability density at every vertex.
        allvxprobs = zeros( totalsegments + numtubules, 1 );
        alllengths = zeros( totalsegments + numtubules, 1 );
        allfreebranchingtubules = zeros( totalsegments + numtubules, 1, 'int32' );
        allsegindexes = zeros( totalsegments + numtubules, 1, 'int32' );
        ai = 0;
        for ii=1:numtubules
            track = m.tubules.tracks(ii);
            vxci = track.vxcellindex;
            vxbcs = track.barycoords;

            ns = length( track.segmentlengths );
            range = (ai+1):(ai+ns);
            % The reshape is necessary because Matlab arrays are fucked.
            allvxprobs( [range, ai+ns+1] ) = sum( reshape( branchPerVertex( m.tricellvxs( vxci, : ) ), [], 3 ) .* vxbcs, 2 );
            alllengths( range ) = track.segmentlengths;
            allfreebranchingtubules( range ) = ii;
            allsegindexes( range ) = 1:ns;

            CURVATURE_EFFECT_ON_BRANCHING = 1;
            if CURVATURE_EFFECT_ON_BRANCHING ~= 0
                alldirglobals = [ track.globalcoords(2:end,:) - track.globalcoords(1:(end-1),:); [0 0 0] ];
                alldirglobals = alldirglobals ./ sqrt(sum(alldirglobals.^2,2));
                alldirglobals(end,:) = track.directionglobal;
                trackcurvaturePerVertex = directionalCurvature( m, track.vxcellindex, track.barycoords, alldirglobals );
                if any( trackcurvaturePerVertex < 0 )
                    xxxx = 1;
                end
                trackcurvaturePerVertex = abs(trackcurvaturePerVertex);
                curvatureEffectPerVertex = CURVATURE_EFFECT_ON_BRANCHING * sum( reshape( branchPerCurvature( m.tricellvxs( vxci, : ) ), [], 3 ) .* vxbcs, 2 );
                allvxprobs( [range, ai+ns+1] ) = allvxprobs( [range, ai+ns+1] ) + curvatureEffectPerVertex .* trackcurvaturePerVertex.^m.tubules.tubuleparams.curvature_power;
                if any( trackcurvaturePerVertex > 0 )
                    xxxx = 1;
                end
            end
            xxxx = 1;

            ai = ai+ns+1;
        end

        [freeBglobalsegindexes, freeBranchSegbc, freeBranchTimes] = samplePiecewiseLinear( allvxprobs, alllengths(1:(end-1)), dt );
        numfreebranches = length(freeBglobalsegindexes);
        freeBranchTubules = allfreebranchingtubules( freeBglobalsegindexes );
        freeBlocalsegindexes = allsegindexes( freeBglobalsegindexes );
        if numfreebranches > 0
            xxxx = 1;
        end

    end
    
    if numel( m.tubules.tubuleparams.prob_tail_branch_time )==1
        tailbranchprobtime = m.tubules.tubuleparams.prob_tail_branch_time;
    else
        tailBranchPerVertex = leaf_getTubuleParamsPerVertex( m, 'prob_tail_branch_time' );
        tailbranchprobtime = zeros( numtubules, 1 );
        tailFEs = zeros( numtubules, 1 );
        tailBcs = zeros( numtubules, 3 );
        for ii=1:numtubules
            track = m.tubules.tracks(ii);
            vxci = track.vxcellindex;
            vxbcs = track.barycoords;

            tailbranchprobtime(ii) = sum( reshape( tailBranchPerVertex( m.tricellvxs( vxci(1), : ) ), [], 3 ) .* vxbcs(1,:), 2 );
            tailFEs(ii) = vxci(1);
            tailBcs(ii,:) = vxbcs(1,:);
        end
        if doBranchScaling
            tailScaling = interpolateOverMesh( m, branchScalingPerVertex, tailFEs, tailBcs, m.tubules.tubuleparams.branch_scaling_interp_mode );
            tailbranchprobtime = tailbranchprobtime .* tailScaling;
        end
    end
    
    if all(tailbranchprobtime==0)
        numtailbranches = 0;
        tailBranchTubules = zeros(0,1);
    else
        tailbranchprobstep = 1 - exp( -dt * tailbranchprobtime );  % Should use [numevents,times] = poissevents( tailbranchprobtime, dt )
        tailbranches = rand(numtubules,1) < tailbranchprobstep;
        tailBranchTubules = find( tailbranches );
        numtailbranches = length( tailBranchTubules );
        if numtailbranches > 0
            xxxx = 1;
        end
    end
    
    numRequestedBranches = numfreebranches + numtailbranches;
    % Account for the limited supply of microtubule heads.
    numNewTubules = requestMTcreation( m, numRequestedBranches );
    if numNewTubules==0
        return;
    end
    selectedTubules = randsubset( numRequestedBranches, numNewTubules );
    
    tailBsegindexes = ones( numtailbranches, 1 );
    tailBranchSegbc = [ ones( numtailbranches, 1 ), zeros( numtailbranches, 1 ) ];
    tailBranchTimes = rand( numtailbranches, 1 );

    bsegindexes = [ freeBlocalsegindexes; tailBsegindexes ];
    branchSegbc = [ freeBranchSegbc; tailBranchSegbc ];
    branchTimes = [ freeBranchTimes; tailBranchTimes ];
    branchTubules = [ freeBranchTubules; tailBranchTubules ];
    
    numSelectedFreeBranches = sum(selectedTubules <= numfreebranches);
    numSelectedTailBranches = sum(selectedTubules > numfreebranches);
    fprintf( 1, 'General branches: %d. Tail branches: %d.\n', numSelectedFreeBranches, numSelectedTailBranches );
    selbsegindexes = bsegindexes( selectedTubules );
    selbranchSegbc = branchSegbc( selectedTubules, : );
    selbranchTimes = branchTimes( selectedTubules );
    selbranchingTubules = branchTubules( selectedTubules );
    
    selbranchElements0 = zeros( numNewTubules, 1 );
    selbranchElements1 = zeros( numNewTubules, 1 );
    selbranchBcs0 = zeros( numNewTubules, 3 );
    selbranchBcs1 = zeros( numNewTubules, 3 );
    for si=1:numNewTubules
        s = m.tubules.tracks( selbranchingTubules(si) );
        selbranchElements0(si) = s.vxcellindex( selbsegindexes(si) );
        selbranchBcs0(si,:) = s.barycoords( selbsegindexes(si), : );
        if length(s.vxcellindex) == 1
            selbranchElements1(si) = selbranchElements0(si);
            selbranchBcs1(si,:) = selbranchBcs0(si,:);
        else
            selbranchElements1(si) = s.vxcellindex( selbsegindexes(si)+1 );
            selbranchBcs1(si,:) = s.barycoords( selbsegindexes(si)+1, : );
        end
    end
    paramsNeeded = { 'prob_branch_forwards', ...
                     'prob_branch_parallel', ...
                     'prob_branch_antiparallel', ...
                     'branch_forwards_mean', ...
                     'branch_forwards_spread', ...
                     'branch_backwards_mean', ...
                     'branch_backwards_spread' };
    paramValues0 = getTubuleParamsModifiedByMorphogens( m, selbranchElements0, selbranchBcs0, paramsNeeded );
    paramValues1 = getTubuleParamsModifiedByMorphogens( m, selbranchElements1, selbranchBcs1, paramsNeeded );
    paramValues = struct();
    for pi=1:length(paramsNeeded)
        fn = paramsNeeded{pi};
        paramValues.(fn) = paramValues0.(fn) .* selbranchSegbc(:,1) + paramValues1.(fn) .* selbranchSegbc(:,2);
    end
    
    branchSides = randSign(numNewTubules,1);
    branchAnglesOld = getMTBranchingAngles( m, numNewTubules, 'free' ) .* branchSides;
    
    branchAnglesNew = getMTLocalBranchingAngles( numNewTubules, paramValues );
    
    branchAngles = branchAnglesNew;
    xxxx = 1;
    % Get the elements and bcs of the tail ends of the
    % selected tubules.
%     branchAngles1 = getTubuleParamsModifiedByMorphogens( m, selBranchElements, selBranchBcs, paramsNeeded );

    
    
    
    
    if numtailbranches > 0
        xxxx = 1;
    end
    [m,newbranchinfo] = spawnBranches( m, selbranchingTubules, selbsegindexes, selbranchSegbc, selbranchTimes, branchSides, branchAngles );
    
    oldStatsWidth = size(m.tubules.statistics.spontbranchinfo,2);
    newStatsWidth = size(newbranchinfo,2);
    if oldStatsWidth < newStatsWidth
        m.tubules.statistics.spontbranchinfo( :, (oldStatsWidth+1):newStatsWidth ) = NaN;
    end
    m.tubules.statistics.spontbranchinfo = [ m.tubules.statistics.spontbranchinfo; newbranchinfo ];

end

