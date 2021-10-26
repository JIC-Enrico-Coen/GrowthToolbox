function [pbc,d,collision,collisiontype] = capsuleApproachToDistance( p01, q01, d0, minangle )
%[pbc,d,collision,collisiontype] = capsuleApproachToDistance( p01, q01, d0, minangle )
%   p00 and q01 are 2xD matrices whose rows are points in D-dimensional
%   space. Each thus defines a line segment.
%
%   This procedure answers the question, if we proceed from p0 to p1, which
%   is the first point to come within a distance d0 of q01?
%
%   The answer is in the form of barycentric coordinates of p01: the
%   selected point is a*p01(0,:) + b*p01(1,:). d is the actual distance of
%   this point from q01.
%
%   If there is no such point, then d is returned as Inf and a and b as 0
%   and 1 (representing the last point of p01).
%
%   collision is a boolean saying whether the segments collide or not.
%
%   collisiontype is a string representing the reason for determining the
%   collision:
%
%   'ZERO'  No collision. d0 is <= zero.
%
%   'ONEPOINT'  p01 is a single point. This is deemed not to collide with
%           anything.
%
%   'EQPOINT'  p0 and p1 coincide. This is deemed not to collide with
%           anything.
%
%   'P<Q'   No collision. The maximum of some p01 coordinate was less
%           than the minimum of the correesponding q01 coordinate by
%           d0 or more.  This is a quick screening test.
%
%   'P>Q'   No collision. Similarly to 'P<Q' with p01 and q01 interchanged.
%
%   'FAR_INF'  No collision. The infinite lines do not come within a
%           distance d0 of each other.
%
%   'FAR_SEGMENTS'  No collision. The infinite lines approach each
%           other, but the segments do not.
%
%   'AWAY'  p01 begins within a distance d0 of the segment q01, but is
%           moving away from it. This is deemed not a collision.
%
%   'FAR3'  No collision. The segments do not come within a distance
%           d0 of each other.
%
%   'FAR4'  No collision. The segments do not come within a distance
%           d0 of each other.
%
%   'PMID_QEND1'  Collision. The segment p01 approaches to a distance d0
%           from an endpoint of q01.
%
%   'FAR5'  No collision. The segments do not come within a distance
%           d0 of each other.
%
%   'ALREADY1'  Collision. The start of p01 is within a distance d0 of an
%           endpoint of q01, and getting closer.
%
%   'APPROACH'  No collision. p01 if prolonged will come within d0 of an
%           end of q01, but the segment p01 does not.
%
%   'MID'   Collision.  A point within p01 comes within d0 of a point
%           within q1.
%
%   'FAR6'  No collision. The segments do not come within a distance
%           d0 of each other.
%
%   'ALREADY2'  Collision. The start of p01 is within a distance d0 of an
%           endpoint of q01, and getting closer.
%
%   'PEND_QEND'  Collision.  The end of p01 comes within d0 of q01. (This
%           is expected to be very rare. Either a point before the end of
%           p01 will do this, or a point beyond the end.)
%
%   'PSTART_QEND'  Collision. The start of p01 is a distance d0 from an
%           endpoint of q01. Also expected to be rare.
%
%   'PMID_QEND2'  Collision. A point within p01 comes within a distance d0
%           of an endpoint of q01.

    VERBOSE = false;

    if d0 <= 0
        % THIS IS WRONG.
        pbc = [0 1];
        d = Inf;
        collision = false;
        collisiontype = 'ZERO';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    if size(p01,1)==1
        pbc = [1 0];
        d = Inf;
        collision = false;
        collisiontype = 'ONEPOINT';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    pbc = [0 1];
    d = Inf;
    
    if size(p01,2) < 3
        p01(end,3) = 0;
    end
    if size(q01,2) < 3
        q01(end,3) = 0;
    end
    
    % Screening test.
    if any( min(q01,[],1) - max(p01,[],1) >= d0 )
        % No collision.
        collision = false;
        collisiontype = 'P<Q';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    if any( min(p01,[],1) - max(q01,[],1) >= d0 )
        % No collision.
        collision = false;
        collisiontype = 'P>Q';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    TOLERANCE = 1e-5;

    % Find the point of closest approach of the two infinite lines.
    [dpq,ps,pbc,qs,qbc,parallel] = lineLineDistance( p01, q01, true );
    
    if dpq >= d0
        collision = false;
        collisiontype = 'FAR_INF';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
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
        pbc = [1 0];
        d = Inf;
        collision = false;
        collisiontype = 'EQPOINT';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
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
            qbc = qbc([2 1]);
        end
        sinLineAngle = sqrt( 1 - cosLineAngle^2 );

        % Find the intersection of the segment p01 with the cylinder segment
        % q01, if any.
        
        d_along_p = sqrt( d0^2 - dpq^2 )/sinLineAngle;  % INCOMPLETE: sinLineAngle might be zero.
        dpbc = d_along_p/p01length;
        pbc1 = trimbc( pbc + [dpbc, -dpbc], TOLERANCE );
        pbc2 = trimbc( pbc + [-dpbc, dpbc], TOLERANCE );

        d_along_q = d_along_p*cosLineAngle;
        dqbc = d_along_q/q01length;
        qbc1 = trimbc( qbc + [dqbc, -dqbc], TOLERANCE );
        qbc2 = trimbc( qbc + [-dqbc, dqbc], TOLERANCE );

        if ((pbc1(1) <= 0) && (pbc2(1) <= 0)) ...
                || ((pbc1(2) <= 0) && (pbc2(2) <= 0)) ...
                || ((qbc1(1) <= 0) && (qbc2(1) <= 0)) ...
                || ((qbc1(2) <= 0) && (qbc2(2) <= 0))
            % The collision segment lies outside either the segment p01 or the segment q01.
            % No collision for the cylinder volume.
    %         fprintf( 1, '%s: No intersection with cylinder.\n', mfilename() );
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

            approaches(:,:,1) = [ pbc1b; pbc2b; pbc; qbc1b; qbc2b ];
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
        pbc = [0 1];
        collision = false;
        collisiontype = 'FAR_SEGMENTS';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
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
        pbc = [0 1];
        collision = false;
        collisiontype = 'APPROACHING';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    [last_collide_pbc2,last_collide_i] = min( approaches(PLAST,2,:), [], 3 );
    if last_collide_pbc2 <= 0
        % No collision. The segment p01 is departing from the segment q01
        % and is already far.
        pbc = [0 1];
        collision = false;
        collisiontype = 'DEPARTED';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    if first_collide_pbc1 < 1
        % p0 is not in range of the segment q01 but some later point of the
        % segment is. That is the collision point.
        pbc = approaches(PFIRST,:,first_collide_i);
        atype = approachtypes{ approachindexes(first_collide_i) };
        collision = true;
        collisiontype = [ 'PMID_' atype ];
        d = d0;
        
        if all(pbc ~= 0) && any(pbc < 1e-6)
            xxxx = 1;
        end
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    % p0 is already in collision range. We must determine whether it is
    % approaching or departing.
    
    midpoints = approaches(PMID,2,:);
    % Are all of the midpoints before p0?
    if max(midpoints) <= 0
        % All the midpoints are before p0. Departing, deemed noncollision.
        pbc = [0 1];
        collision = false;
        collisiontype = 'DEPARTING';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    pbc = [1 0];
    collision = true;
    collisiontype = 'ALREADY';

    if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
end