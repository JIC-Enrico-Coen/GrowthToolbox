function [m,newbranchinfo,newmtindexes] = spawnBranches( m, branchingTubules, branchSegments, branchSegbc, branchTimes, branchSides, branchAngles )
%[m,newbranchinfo,newmtindexes] = spawnBranches( m, branchingTubules, branchSegments, branchSegbc, branchTimes, branchSides, branchAngles )
%   Create new tubules branching off from existing ones.
%   BRANCHINGTUBULES is a list of the tubules that are to spawn new
%   branches.
%   BRANCHSEGMENTS specifies the respective segments they are to branch
%   from.
%   BRANCHSEGBC gives the barycentric coordinates within each segment
%   where the branch point is to be.
%   BRANCHTIMES are the times at which the branches are created.
%   BRANCHSIDES specifies which side of the parent each branch is to be.
%   BRANCHANGLES specifies the angles (value from 0 to 180) between the
%   parents and the branches.
%
%   NEWBRANCHINFO is an N*6 array, with one row for each branching. The
%   elements are:
%       the finite element in which it happens
%       the three bary coords of the point where it happens
%       the model time
%       the branching angle (as a signed angle in the range (-180...180].

    numNewTubules = length( branchingTubules );
    newbranchinfo = zeros( numNewTubules, 6 );
    newbranchinfo(:,5) = double(Steps(m)+1);
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
        if branchSegbc(1) >= 1
            globalStart = segGlobalStart;
            if segi==length( m.tubules.tracks(mti).vxcellindex )
                globalDirection = m.tubules.tracks(mti).directionglobal;
            else
                segGlobalEnd = m.tubules.tracks(mti).globalcoords( segi+1, : );
                globalDirection = segGlobalEnd - segGlobalStart;
            end
        else
            segGlobalEnd = m.tubules.tracks(mti).globalcoords( segi+1, : );
            globalStart = branchSegbc(ii,1) .* segGlobalStart + branchSegbc(ii,2) .* segGlobalEnd;
            globalDirection = segGlobalEnd - segGlobalStart;
        end
        elementNormal = m.unitcellnormals( segelement, : );
        transverse = makeframe( elementNormal, globalDirection ) * ((m.tubules.tubuleparams.radius + m.tubules.tubuleparams.headradius) * 1.0005); % The extra 0.0005 is to provide initial clearance.
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
        newbranchinfo(ii,1:4) = [ double(segelement), theStartBcs ];
        newbranchinfo(ii,6) = branchAngle;
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
    
    newmtindexes = getNumberOfTubules( m ) - numOldStreamlines;
end