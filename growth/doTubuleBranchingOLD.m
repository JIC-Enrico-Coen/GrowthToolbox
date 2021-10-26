function m = doTubuleBranchingOLD( m, dt )
%m = doTubuleBranchingOLD( m, dt )
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
    varBranchPerLength = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_length_time' ) );
    varBranchPerTubule = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_tubule_time' ) );
    varBranchPerTime = max( 0, leaf_getTubuleParamsPerVertex( m, 'prob_branch_time' ) );
%     branchPerLength = m.tubules.tubuleparams.prob_branch_length_time;
%     branchPerTubule = m.tubules.tubuleparams.prob_branch_tubule_time;
%     branchPerTime = m.tubules.tubuleparams.prob_branch_time;
    ease_of_creation = limitMTcreation( m );
    
    varBranchPerLength = varBranchPerLength * ease_of_creation;
    varBranchPerTubule = varBranchPerTubule * ease_of_creation;
    varBranchPerTime = varBranchPerTime * ease_of_creation;
    maxBranchPerLength = max( varBranchPerLength );
    maxBranchPerTubule = max( varBranchPerTubule );
    maxBranchPerTime = max( varBranchPerTime );
    
    if (maxBranchPerLength <= 0) && (maxBranchPerTubule <= 0) && (maxBranchPerTime <= 0)
        return;
    end
    
    % Determine how many new mts will be created, and how many on each
    % existing MT. If none, return.
    allCumLengths = cell( numtubules, 1 );
    mtLengths = zeros( numtubules, 1 );
    for mti=1:numtubules
        allCumLengths{mti} = [0 cumsum( m.tubules.tracks(mti).segmentlengths ) ]';
        mtLengths(mti) = allCumLengths{mti}(end);
    end
    totalTubuleLength = sum( mtLengths );
    if totalTubuleLength <= 0
        return;
    end
    
    if any(maxBranchPerTime > 0)
        branchPerVertex = varBranchPerLength;
        totalRate = maxBranchPerTime;
    elseif any(maxBranchPerTubule > 0)
        branchPerVertex = varBranchPerTubule;
        totalRate = numtubules*maxBranchPerTubule;
    else
        branchPerVertex = varBranchPerLength;
        totalRate = totalTubuleLength*maxBranchPerLength;
    end
    [numNewTubules,creationtimes] = poissevents( totalRate, dt );
%     rateMod = branchPerVertex/totalRate;
    rateMod = branchPerVertex/max(branchPerVertex);
    if sum(numNewTubules)==0
        return;
    end
    
    creationtimes = creationtimes(:) + m.globalDynamicProps.currenttime;
    ntGlobalPoints = sort( rand(numNewTubules,1) * totalTubuleLength );
    cmtLengths = cumsum( [0; mtLengths] );
    branchingTubules = binsearchall( cmtLengths, ntGlobalPoints ) - 1;
    ntLocalPoints = ntGlobalPoints - cmtLengths( branchingTubules );
    branchSides = rand(numNewTubules,1) < 0.5;
    branchAngles = getMTBranchingAngles( m, numNewTubules ) .* branchSides;
    
    % Determine the data for creating all the new MTs, as required by
    % leaf_createStreamlines. newStartElements, newStartBcs, and newDirBcs
    % will hold these data.
    numnewMTs = 0;
    newStartElements = zeros( numNewTubules, 1 );
    newStartBcs = zeros( numNewTubules, 3 );
    newDirBcs = zeros( numNewTubules, 3 );
    
    for ii=1:numNewTubules
        mti = branchingTubules(ii);
        cumLengths = allCumLengths{mti};
        branchPoint = ntLocalPoints(ii);
        branchSegment = binsearchupper( cumLengths, branchPoint );
        branchInSegmentBc = (branchPoint - cumLengths(branchSegment-1))./(cumLengths(branchSegment) - cumLengths(branchSegment-1));
        branchSide = branchSides(ii);
        segGlobalStart = m.tubules.tracks(mti).globalcoords( branchSegment-1, : );
        segGlobalEnd = m.tubules.tracks(mti).globalcoords( branchSegment, : );
        segElement = findMTSegmentElement( m.tubules.tracks(mti), branchSegment-1 );
        
        % Calculate the points along the segments where they happen, the
        % direction of the parent MT at that point, and the transverse
        % unit vector.
        globalStart = (1 - branchInSegmentBc) .* segGlobalStart + branchInSegmentBc .* segGlobalStart;
        globalDirection = segGlobalEnd - segGlobalStart;
        elementNormal = m.unitcellnormals( segElement, : );
        transverse = makeframe( elementNormal, globalDirection ) * (m.tubules.tubuleparams.radius * 2.001); % The extra 0.001 is to provide initial clearance.
        transverse = transverse .* branchSide;
        
        % Displace the creation point along the transverse vector by the
        % tubule diameter, randomly to one side or to the other.
        globalStart = globalStart + transverse;
        
        branchAngle = branchAngles(ii);
        
        % Calculate the creation data for the new MT. This data consists of
        % the element where this happens, the barycentric coodinates of the
        % start point, and the directional bcs of the initial direction.
        elementVxs = m.nodes( m.tricellvxs( segElement, : ), : );
        [theStartBcs,bc_err] = baryCoords( elementVxs, elementNormal, globalStart, true );
        newDirectionGlobal = rotateVecAboutVec( globalDirection, m.unitcellnormals( segElement, : ), branchAngle );
        [theDirBcs,dbc_err] = baryDirCoords( elementVxs, elementNormal, newDirectionGlobal );
%         fprintf( 1, '%s: bcerr %g dbcerr %g\n', mfilename(), bc_err, dbc_err );
%         fprintf( 1, '%s: An mt will be spawned on mt %d at [%g %g %g] in direction [%g %g %g] at angle %g\n', ...
%             mfilename(), mti, globalStart, newDirectionGlobal, branchAngle );
        if (bc_err > 0.1) || (dbc_err > 0.1)
            xxxx = 1;
        end
        numnewMTs = numnewMTs+1;
        newStartElements(numnewMTs) = segElement;
        newStartBcs(numnewMTs,:) = theStartBcs;
        newDirBcs(numnewMTs,:) = theDirBcs;
    end
    
    if any( rateMod < 1 )
        rateModPerElementVx = rateMod( m.tricellvxs(newStartElements,:) );
        if size(rateModPerElementVx,2)==1
            % Because Matlab arrays are fucked.
            rateModPerElementVx = rateModPerElementVx';
        end
        probPerBranching = sum( newStartBcs .* rateModPerElementVx, 2 );
        keepBranchings = rand(size(probPerBranching)) < probPerBranching;
        numnewMTs = sum( keepBranchings );
        if numnewMTs==0
            return;
        end
        newStartElements = newStartElements( keepBranchings );
        newStartBcs = newStartBcs( keepBranchings, : );
        newDirBcs = newDirBcs( keepBranchings, : );
        creationtimes = creationtimes( keepBranchings );
    end
    
    fprintf( 1, '%s: %d mts will branch off.\n', mfilename(), numNewTubules );
    
    % Create all the new mts at once
    numOldStreamlines = getNumberOfTubules( m );
    m = leaf_createStreamlines( m, ...
            'elementindex', newStartElements, ...
            'barycoords', newStartBcs, ...
            'directionbc', newDirBcs, ...
            'creationtimes', creationtimes );

    % Set up tail shrink delays.
    if m.tubules.tubuleparams.branch_shrinktail_delay > 0
        for i=(numOldStreamlines+1):getNumberOfTubules( m )
            m.tubules.tracks(i).status.shrinktail = false;
            m.tubules.tracks(i).status.shrinktime = m.globalDynamicProps.currenttime + m.tubules.tubuleparams.branch_shrinktail_delay;
        end
    end
    
    % Update stats.
    if ~isfield(  m.tubules.statistics, 'branchings' )
        m.tubules.statistics.branchings = 0;
    end
    m.tubules.statistics.branchings = m.tubules.statistics.branchings + numnewMTs;
end

