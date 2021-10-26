function m = doTubuleBranching( m, dt )
%m = doTubuleBranching( m, dt )
%   Randomly create microtubules branching off existing microtubules during
%   a small time interval dt. There are three mutually exclusive methods of
%   specifying branching rates.
%
%   1. There may be a global rate of making new branches per unit time.
%   This is specified  by m.tubules.tubuleparams.prob_branch_time.
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
%   and used to calculate the length of its first step.

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
    
    branchPerVertex = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_length_time' ) );
    branchPerCurvature = leaf_getTubuleParamsPerVertex( m, 'prob_branch_length_curvature_time' );
        

    % Decide where along the current MT new MTs will be spawned, and
    % on which side. Since we already know how many will be spawned,
    % their spawning points are uniformly distributed along the length
    % of the current MT. We do not take the trouble to ensure that two
    % MTs are not spawned at overlapping positions, nor do we handle
    % what happens if the spawning point should be across the edge of a
    % finite element and into a neighbouring element. This code is
    % therefore only valid if the mt diameter is small compared to
    % element side and the expected distance between spawning points.
    % We also do not test to see if there is an existing MT where the
    % new one is to be created. With MTs tending to grow in bundles,
    % this might be an important omission. Perhaps
    % leaf_createStreamlines should make this check.
    
    % Count the number of segments in all microtubules.
    totalsegments = length( [m.tubules.tracks.segmentlengths] );
    
    % Find the branching probability density at every vertex.
    allvxprobs = zeros( totalsegments + numtubules, 1 );
    alllengths = zeros( totalsegments + numtubules, 1 );
    alltubules = zeros( totalsegments + numtubules, 1, 'int32' );
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
        alltubules( range ) = ii;
        allsegindexes( range ) = 1:ns;
        
        alldirglobals = [ track.globalcoords(2:end,:) - track.globalcoords(1:(end-1),:); [0 0 0] ];
        alldirglobals = alldirglobals ./ sqrt(sum(alldirglobals.^2,2));
        alldirglobals(end,:) = track.directionglobal;
        trackcurvaturePerVertex = directionalCurvature( m, track.vxcellindex, track.barycoords, alldirglobals );
        if any( trackcurvaturePerVertex < 0 )
            xxxx = 1;
        end
        trackcurvaturePerVertex = abs(trackcurvaturePerVertex);
        CURVATURE_EFFECT_ON_BRANCHING = 1;
        curvatureEffectPerVertex = CURVATURE_EFFECT_ON_BRANCHING * sum( reshape( branchPerCurvature( m.tricellvxs( vxci, : ) ), [], 3 ) .* vxbcs, 2 );
        allvxprobs( [range, ai+ns+1] ) = allvxprobs( [range, ai+ns+1] ) + curvatureEffectPerVertex .* trackcurvaturePerVertex;
        xxxx = 1;
        
        ai = ai+ns+1;
    end
    [bsegindexes, branchSegbc, branchTimes] = samplePiecewiseLinear( allvxprobs, alllengths(1:(end-1)), dt );
    numNewTubulesRequested = length(bsegindexes);
    if numNewTubulesRequested > 0
        xxxx = 1;
    end
    
    % Account for the limited supply of microtubule heads.
    numNewTubules = requestMTcreation( m, numNewTubulesRequested );
    if numNewTubules==0
        return;
    end
    selectedTubules = randsubset( numNewTubulesRequested, numNewTubules );
    bsegindexes = bsegindexes( selectedTubules );
    branchSegbc = branchSegbc( selectedTubules, : );
    branchTimes = branchTimes( selectedTubules );
    
    xxxx = 1;
    
    branchingTubules = alltubules(bsegindexes);
    if any(branchingTubules==0)
        xxxx = 1;
    end
    branchSegments = allsegindexes(bsegindexes);
    branchSides = rand(numNewTubules,1) < 0.5;
    branchAngles = getMTBranchingAngles( m, numNewTubules ) .* branchSides;
    
    branchElements = zeros( numNewTubules, 1, 'int32' );
    startBcs = zeros( numNewTubules, 3 );
    startDirBcs = zeros( numNewTubules, 3 );
    for ii=1:length(branchingTubules)
        mti = branchingTubules(ii);
        segi = branchSegments(ii);
        segelement = m.tubules.tracks(mti).segcellindex( segi );
        branchElements(ii) = segelement;
        
        % Calculate the global coordinates of the points along the segments
        % where the branchings happen, the direction of the parent MT at
        % that point, and the transverse unit vector.
        segGlobalStart = m.tubules.tracks(mti).globalcoords( segi, : );
        segGlobalEnd = m.tubules.tracks(mti).globalcoords( segi+1, : );
        globalStart = (1 - branchSegbc(ii)) .* segGlobalStart + branchSegbc(ii) .* segGlobalStart;
        globalDirection = segGlobalEnd - segGlobalStart;
        elementNormal = m.unitcellnormals( segelement, : );
        transverse = makeframe( elementNormal, globalDirection ) * (m.tubules.tubuleparams.radius * 2.001); % The extra 0.001 is to provide initial clearance.
        transverse = transverse .* branchSides(ii);
        
        % Displace the creation point along the transverse vector by the
        % tubule diameter, randomly to one side or to the other.
        globalStart = globalStart + transverse;
        
        % Calculate the creation data for the new MT. This data consists of
        % the element where this happens, the barycentric coodinates of the
        % start point, and the directional bcs of the initial direction.
        branchAngle = branchAngles(ii);
        elementVxs = m.nodes( m.tricellvxs( segelement, : ), : );
        [theStartBcs,bc_err] = baryCoords( elementVxs, elementNormal, globalStart, true );
        newDirectionGlobal = rotateVecAboutVec( globalDirection, m.unitcellnormals( segelement, : ), branchAngle );
        [theDirBcs,dbc_err] = baryDirCoords( elementVxs, elementNormal, newDirectionGlobal );
%         fprintf( 1, '%s: bcerr %g dbcerr %g\n', mfilename(), bc_err, dbc_err );
%         fprintf( 1, '%s: An mt will be spawned on mt %d at [%g %g %g] in direction [%g %g %g] at angle %g\n', ...
%             mfilename(), mti, globalStart, newDirectionGlobal, branchAngle );
        if (bc_err > 0.1) || (dbc_err > 0.1)
            xxxx = 1;
        end
        startBcs(ii,:) = trimbc( theStartBcs );
        startDirBcs(ii,:) = theDirBcs;
    end
        
    numOldStreamlines = getNumberOfTubules( m );
    m = leaf_createStreamlines( m, ...
            'elementindex', branchElements, ...
            'barycoords', startBcs, ...
            'directionbc', startDirBcs, ...
            'creationtimes', branchTimes + m.globalDynamicProps.currenttime );
    
    globalLocations = shiftdim( sum( reshape( m.nodes( m.tricellvxs( branchElements, : )' , : ), 3, [], 3 ) .* startBcs', 1 ), 1 );
    if ~isfield( m.auxdata, 'branchPoints' )
        m.auxdata.branchPoints = zeros(0,3);
    end
    m.auxdata.branchPoints = [ m.auxdata.branchPoints; globalLocations ];

    % Set up tail shrink delays.
    if m.tubules.tubuleparams.branch_shrinktail_delay > 0
        for ii=(numOldStreamlines+1):getNumberOfTubules( m )
            m.tubules.tracks(ii).status.shrinktail = false;
            m.tubules.tracks(ii).status.shrinktime = m.globalDynamicProps.currenttime + m.tubules.tubuleparams.branch_shrinktail_delay;
        end
    end
    
    % Update stats.
    if ~isfield(  m.tubules.statistics, 'branchings' )
        m.tubules.statistics.branchings = 0;
    end
    m.tubules.statistics.branchings = m.tubules.statistics.branchings + numNewTubules;
end

