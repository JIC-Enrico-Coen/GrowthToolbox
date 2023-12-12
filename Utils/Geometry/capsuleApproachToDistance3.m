function [pbc_touch,pbc_cross,qbc_touch,qbc_cross] = capsuleApproachToDistance3( p01, q01, d0 )
%[pbc_touch,pbc_cross,qbc_touch,qbc_cross] = capsuleApproachToLine( p01, q01, d0 )
%   p01 and q01 are 2xD matrices whose rows are points in D-dimensional
%   space. Each thus defines a line segment.
%
%   This procedure answers the question, if we proceed from p0 to p1, at
%   what point do we intersect the infinite line through q01, and at what
%   point do we come within a distance d0 of that line?
%
%   The answer is in the form of barycentric coordinates of p01 and q01.
%   pbc_touch is the point that first comes within distance d0 of q01.
%   pbc_cross is the intersection point. qbc_cross is the intersection
%   point relative to q01.

    VERBOSE = false;
    MAKE_FIGURE = false;
    
    pbc_touch = [];
    pbc_cross = [];
    qbc_touch = [];
    qbc_cross = [];

    if size(p01,1)==1
        if VERBOSE, timedFprintf( 1, 'p01 is only one point.\n' ); end
        return;
    end
    
    % Force the points to be in 3D.
    if size(p01,2) < 3
        p01(end,3) = 0;
    end
    if size(q01,2) < 3
        q01(end,3) = 0;
    end
    
    % Screening test.
    if any( min(q01,[],1) - max(p01,[],1) >= d0 ) || any( min(p01,[],1) - max(q01,[],1) >= d0 )
        % No collision.
        if VERBOSE, timedFprintf( 1, 'No collision, screening test false.\n' ); end
        return;
    end
    
    TOLERANCE = 1e-5;

    % Find the point of closest approach of the two infinite lines.
    [dpq,p_cross,pbc_cross,q_cross,qbc_cross,parallel] = lineLineDistance( p01, q01, true );
    
    if dpq >= d0
        if VERBOSE, timedFprintf( 1, 'No collision, extrapolated lines are too far apart\n' ); end
        return;
    end
    
    
    % Find the angle between the two lines, projected orthogonally to their
    % vector of closest approach.
    separationVector = q_cross - p_cross;
    p_vec = p01(2,:) - p01(1,:);
    q_vec = q01(2,:) - q01(1,:);
    [intersectionAngle,ax,rotmat] = vecangle( p_vec, q_vec );
    p_backOffDistance = abs( csc( intersectionAngle ) ) * d0;
    q_backOffDistance = abs( cot( intersectionAngle ) ) * d0;
    if abs(intersectionAngle) > pi/2
        q_backOffDistance = -q_backOffDistance;
    end
    p_length = norm( p_vec );
    q_length = norm( q_vec );
    p_touch_fraction = pbc_cross(2) - p_backOffDistance/p_length;
    q_touch_fraction = qbc_cross(2) - q_backOffDistance/q_length;
    pbc_touch = [ 1 - p_touch_fraction, p_touch_fraction ];
    qbc_touch = [ 1 - q_touch_fraction, q_touch_fraction ];
    p_touch = pbc_touch * p01;
    q_touch = qbc_touch * q01;
    if any( pbc_cross < 0 ) || any( qbc_cross < 0 )
        if VERBOSE, timedFprintf( 1, 'Crossing outside one or both segments: pbc_cross %f %f, qbc_cross %f %f.\n', pbc_cross, qbc_cross ); end
        pbc_cross = [];
        qbc_cross = [];
        p_cross = [];
        q_cross = [];
    else
        if VERBOSE, timedFprintf( 1, 'Crossing: pbc_cross %f %f, qbc_cross %f %f.\n', pbc_cross, qbc_cross ); end
    end
    if any( pbc_touch < 0 ) || any( qbc_touch < 0 )
        if VERBOSE, timedFprintf( 1, 'Touching outside one or both segments: pbc_touch %f %f, qbc_touch %f %f.\n', pbc_touch, qbc_touch ); end
        pbc_touch = [];
        qbc_touch = [];
    else
        if VERBOSE, timedFprintf( 1, 'Touching: pbc_touch %f %f, qbc_touch %f %f.\n', pbc_touch, qbc_touch ); end
    end
    
    if MAKE_FIGURE
        [f,ax] = getFigure();
        hold(ax,'on');
        plotpts( p01, 'Color', 'b', 'Parent', ax, 'Marker', 'none' );
        plotpts( q01, 'Color', 'r', 'Parent', ax, 'Marker', 'none' );
%         quiver(p1(1),p1(2),dp(1),dp(2),0)
        plotpts( [p01(1,:); q01(1,:)], 'Color', 'k', 'Parent', ax, 'Marker', 'o', 'MarkerFaceColor', 'k', 'LineStyle', 'none' );
        plotpts( [p01(2,:); q01(2,:)], 'Color', 'g', 'Parent', ax, 'Marker', 'o', 'MarkerFaceColor', 'g', 'LineStyle', 'none' );
        qperp = [ -q_vec(2), q_vec(1), q_vec(3) ];
        qperp = qperp * d0 / norm(qperp);
        plotpts( q01+[qperp;qperp], 'Color', 'k', 'Parent', ax, 'Marker', 'none', 'LineStyle', '--' );
        plotpts( q01-[qperp;qperp], 'Color', 'k', 'Parent', ax, 'Marker', 'none', 'LineStyle', '--' );
        if ~isempty( p_cross )
            plotpts( [p_cross;q_cross], 'Color', 'g', 'Parent', ax, 'Marker', 'none' );
            plotpts( [p_cross;q_cross], 'Color', 'k', 'Parent', ax, 'Marker', 'x', 'MarkerFaceColor', 'k', 'LineStyle', 'none', 'MarkerSize', 15 );
        end
        if ~isempty( p_touch )
            plotpts( [p_touch;q_touch], 'Color', [1 0 1], 'Parent', ax, 'Marker', 'none' );
            plotpts( [p_touch;q_touch], 'Color', 'k', 'Parent', ax, 'Marker', 'o', 'MarkerFaceColor', 'none', 'LineStyle', 'none' );
        end
        bds = axisBoundsFromPoints( [p01;q01], 1, 0.1 );
        axis( ax, 'equal' );
        axis( ax, bds );
        hold(ax,'off');
    end
    
    return;
    
    approachtypes = { 'QMID', 'QBEGIN', 'QEND' };
    numapproachtypes = length(approachtypes);
    PFIRST = 1;
    PLAST = 2;
    PMID = 3;
    approaches = zeros(5,2,numapproachtypes);
    approachindexes = 1:numapproachtypes;
    approached = false( 1, numapproachtypes );
    dp = p01(2,:)-p01(1,:);
    dq = q01(2,:)-q01(1,:);
    p01length = norm(dp);
    if p01length==0
        pbc_cross = [1 0];
        d = Inf;
        collision = false;
        collisiontype = 'EQPOINT';
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    q01length = norm(dq);
    haveCylinder = q01length > 0;
    if haveCylinder
        cosLineAngle = dot( dp, dq )/(norm(dp)*norm(dq));
        if cosLineAngle < 0
            % Change the sense of q01 to agree with that of p01.
            cosLineAngle = -cosLineAngle;
            q01 = q01([2 1],:);
            qbc_cross = qbc_cross([2 1]);
        end
        sinLineAngle = sqrt( 1 - cosLineAngle^2 );

        % Find the intersection of the segment p01 with the cylinder segment
        % q01, if any.
        
        d_along_p = sqrt( d0^2 - dpq^2 )/sinLineAngle;  % INCOMPLETE: sinLineAngle might be zero.
        dpbc = d_along_p/p01length;
        pbc1 = trimbc( pbc_cross + [dpbc, -dpbc], TOLERANCE );
        pbc2 = trimbc( pbc_cross + [-dpbc, dpbc], TOLERANCE );

        d_along_q = d_along_p*cosLineAngle;
        dqbc = d_along_q/q01length;
        qbc1 = trimbc( qbc_cross + [dqbc, -dqbc], TOLERANCE );
        qbc2 = trimbc( qbc_cross + [-dqbc, dqbc], TOLERANCE );

        if ((pbc1(1) <= 0) && (pbc2(1) <= 0)) ...
                || ((pbc1(2) <= 0) && (pbc2(2) <= 0)) ...
                || ((qbc1(1) <= 0) && (qbc2(1) <= 0)) ...
                || ((qbc1(2) <= 0) && (qbc2(2) <= 0))
            % The collision segment lies outside either the segment p01 or the segment q01.
            % No collision for the cylinder volume.
    %         timedFprintf( 1, '%s: No intersection with cylinder.\n', mfilename() );
            xxxx = 1;
        else
            % Trim the segment (pbc1,pbc2) to lie within the segment p01, and
            % adjust (qbc1,qbc2) correspondingly.
            pbc1a = trimnumber( 0, pbc1, 1, TOLERANCE );
            pdbc1a = pbc1a(2) - pbc1(2);
            qdbc1a = (pdbc1a*cosLineAngle)*(p01length/q01length);
            qbc1a = qbc1 + [-qdbc1a, qdbc1a];

            pbc2a = trimnumber( 0, pbc2, 1, TOLERANCE );
            pdbc2 = pbc2a(2) - pbc2(2);
            qdbc2 = (pdbc2*cosLineAngle)*(p01length/q01length);
            qbc2a = qbc2 + [-qdbc2, qdbc2];

            % Now similarly trim qbc* and correspondingly adjust pbc*
            qbc1b = trimnumber( 0, qbc1a, 1, TOLERANCE );
            qdbc1b = qbc1b(2) - qbc1a(2);
            pdbc1b = (qdbc1b/cosLineAngle)*(q01length/p01length);
            pbc1b = pbc1a + [-pdbc1b, pdbc1b];

            qbc2b = trimnumber( 0, qbc2a, 1, TOLERANCE );
            qdbc2b = qbc2b(2) - qbc2a(2);
            pdbc2b = (qdbc2b/cosLineAngle)*(q01length/p01length);
            pbc2b = pbc2a + [-pdbc2b, pdbc2b];

            % These points should be the intersection of the segment p01 with
            % the cylinder segment q01.

            approaches(:,:,1) = [ pbc1b; pbc2b; pbc_cross; qbc1b; qbc2b ];
            approached(1) = true;
        end
    end
    
    % Find the intersection of the segment p01 with each of the spheres
    % around the endpoints of q01.
    
    % Find the point of closest approach of the infinite line p01 to q0.
    % Withdraw and project to find the points exactly d0 from q0.
    % Do the same for q1.
    
    if haveCylinder
        numqends = 2;
    else
        numqends = 1;
    end
    for i=1:numqends
        [dq0p,qp01,pq0bc] = pointLineDistance( p01, q01(i,:), true );
        if dq0p < d0
            d_along_p = sqrt( d0^2 - dq0p^2 );
            dbc = d_along_p/p01length;
            pq0bc1 = trimnumber( 0, pq0bc + [dbc, -dbc], 1, TOLERANCE );
            pq0bc2 = trimnumber( 0, pq0bc + [-dbc, dbc], 1, TOLERANCE );
            qendbc = [0 0];
            qendbc(i) = 1;
            
            approached(i+1) = true;
            approaches(:,:,i+1) = [ pq0bc1; pq0bc2; pq0bc; qendbc; qendbc ];
        end
    end
    
    approaches = approaches(:,:,approached);
    approachindexes = approachindexes(approached);
    if isempty(approaches)
        % No collision.
        pbc_cross = [0 1];
        collision = false;
        collisiontype = 'FAR_SEGMENTS';
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    approaching = false(1,length(approachindexes));
    for i=1:length(approachindexes)
        approaching(i) = approaches(PMID,1,i) < approaches(PFIRST,1,i);
    end
    
    [first_collide_pbc1,first_collide_i] = max( approaches(PFIRST,1,:), [], 3 );
    if first_collide_pbc1 <= 0
        % No collision. The segment p01 approaches the segment q01 but does
        % not reach it.
        pbc_cross = [0 1];
        collision = false;
        collisiontype = 'APPROACHING';
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    [last_collide_pbc2,last_collide_i] = min( approaches(PLAST,2,:), [], 3 );
    if last_collide_pbc2 <= 0
        % No collision. The segment p01 is departing from the segment q01
        % and is already far.
        pbc_cross = [0 1];
        collision = false;
        collisiontype = 'DEPARTED';
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    if first_collide_pbc1 < 1
        % p0 is not in range of the segment q01 but some later point of the
        % segment is. That is the collision point.
        pbc_cross = approaches(PFIRST,:,first_collide_i);
        atype = approachtypes{ approachindexes(first_collide_i) };
        collision = true;
        collisiontype = [ 'PMID_' atype ];
        d = d0;
        
        if all(pbc_cross ~= 0) && any(pbc_cross < 1e-6)
            xxxx = 1;
        end
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    % p0 is already in collision range. We must determine whether it is
    % approaching or departing.
    
    midpoints = approaches(PMID,2,:);
    % Are all of the midpoints before p0?
    if max(midpoints) <= 0
        % All the midpoints are before p0. Departing, deemed noncollision.
        pbc_cross = [0 1];
        collision = false;
        collisiontype = 'DEPARTING';
        if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    pbc_cross = [1 0];
    collision = true;
    collisiontype = 'ALREADY';

    if VERBOSE, timedFprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
end