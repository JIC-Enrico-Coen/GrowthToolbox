function [pbc1,qbc1,pbcx,qbcx,d,collision,collisiontype] = capsuleApproachToDistance2( p01, q01, d0 )
%[pbc1,qbc1,pbcx,qbcx,d,collision,collisiontype] = capsuleApproachToDistance2( p01, q01, d0 )
%   p00 and q01 are 2xD matrices whose rows are points in D-dimensional
%   space. Each thus defines a line segment.
%
%   This procedure answers the questions, if we proceed from p0 to p1, which
%   is the first point to come within a distance d0 of q01? And where
%   within the segments do they approach the closest to each other? The
%   barycentric segments of the point of p01 of first approach, and the
%   closest point of q01 to that point, are returned in pbc1 and qbc1.
%
%   If the two line segments also intersect, the barycentric coordinates of
%   the intersection in p01 and q01 are returned in pbcx and qbcx.
%
%   2021 Jun 17  THE BELOW DESCRIPTION IS OUT OF DATE.
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
%   'PMID_QEND'  Collision. The segment p01 approaches to a distance d0
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
%           is expected to be rare. Either a point before the end of
%           p01 will do this, or a point beyond the end.)
%
%   'PSTART_QEND'  Collision. The start of p01 is a distance d0 from an
%           endpoint of q01. Also expected to be rare.

    VERBOSE = false;
    pbc1 = [NaN NaN];
    qbc1 = [NaN NaN];
    pbcx = [NaN NaN];
    qbcx = [NaN NaN];
    d = Inf;
    collisionType = 'NONE';
    collision = false;

    if d0 < 0
        collisiontype = 'ZERO';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    if size(p01,1)==1
        % Should not allow this to happen. p01 and q01 should always
        % consist of two points.
        pbc1 = [1 0];
        qbc1 = [0 0];
        collisiontype = 'ONEPOINT';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    if size(p01,2) < 3
        p01(end,3) = 0;
    end
    if size(q01,2) < 3
        q01(end,3) = 0;
    end
    
    % Screening test.
    ds = min( min(q01,[],1) - max(p01,[],1) );
    if ds >= d0
        % No collision.
        d = ds;
        collisiontype = 'P<Q';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    ds = min(  min(p01,[],1) - max(q01,[],1) );
    if ds >= d0
        % No collision.
        d = ds;
        collisiontype = 'P>Q';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    TOLERANCE = 1e-5;

    % Find the point of closest approach of the two infinite lines.
    % If these points lie on both the line segments, then these are the
    % crossover points.
    [dpq,ps,pbc1,qs,qbc1,parallel] = lineLineDistance( p01, q01, true );
        
    
    % If dpq is greater than d0 then there is no intersection and no crossover.
    if dpq >= d0
        collision = false;
        d = dpq;
        collisiontype = 'FAR_INF';
        if VERBOSE, fprintf( 1, 'Collision %d, %s, dist %d\n', collision, collisiontype, dpq ); end
        return;
    end
    
    if all(pbc1>=0) && all(qbc1>=0)
        % Both points are on their respective line segment, so this is the
        % crossover.
        pbcx = pbc1;
        qbcx = qbc1;
    end
    
    [dp0q01,~,qbc1] = pointLineDistance( q01, p01(1,:), false );
    if dp0q01 < d0
        % p0 is already within distance d0 of q01. We ignore this sort of collision.
        pbc = [1 0];
        qbc = qbc1;
        d = dp0q01;
        collisiontype = 'ALREADY';
        if VERBOSE, fprintf( 1, 'Collision %d, %s, dist %f\n', collision, collisiontype, dp0q01 ); end
        return;
    end
        
    % All of the above was screening tests and special cases.
    % Now we deal with the general case. We know that the infinite line
    % segments approach with a distance < d of each other. Consider the
    % transversal that connects the two points of closest approach. This
    % line is perpendicular to p01 and q01. To simplfy the problem we
    % rotate and translate everything into a frame of reference in which
    % the transversal is parallel to Z and q01 lies on the X axis.
    
    pvec = p01(2,:)-p01(1,:);
    qvec = q01(2,:)-q01(1,:);
    tvec = qs-ps;
    pn = norm(pvec);
    qn = norm(qvec);
    tn = norm(tvec);
    xvec = qvec/qn;
    yvec = pvec/pn;
    MINAXISLENGTH = 1e-8;
    if tn < MINAXISLENGTH
        tvec = cross(qvec,pvec);
        tn = norm(tvec);
    end
    zvec = tvec/tn;
    % What complicates finding the frame is that any or all of pvec, qvec,
    % and tvec might have very small or zero length. We must deal with all
    % possibilities in order to construct the desired frame in a
    % well-conditioned way.
    if qn < MINAXISLENGTH
        if tn < MINAXISLENGTH
            if pn < MINAXISLENGTH
                xvec = [1 0 0];
                yvec = [0 1 0];
                zvec = [0 0 1];
            else
                [zvec, xvec, yvec] = makeframe( yvec );
            end
        else
            if pn < MINAXISLENGTH
                [xvec, yvec, zvec] = makeframe( zvec );
            else
                [xvec,zvec,yvec] = makeframe( zvec, pvec );
                yvec = -yvec;
            end
        end
    elseif tn < MINAXISLENGTH
        if pn < MINAXISLENGTH
            [yvec,zvec,xvec] = makeframe( xvec );
        else
            [zvec,xvec,yvec] = makeframe( xvec, yvec );
        end
    else
        yvec = makeframe( zvec, xvec );
    end
    [~,omitvec] = min( [qn,pn,tn] );
    switch omitvec
        case 1
           xvec = makeframe( yvec, zvec );
        case 2
           yvec = makeframe( zvec, xvec );
        case 3
           zvec = cross(qvec,pvec);
           zvec = zvec/norm(zvec);
           yvec = makeframe( zvec, xvec );
    end
    rotmat = [xvec;yvec;zvec]';
    
    % At last we have the frame of reference. Rotate p01 and q01 into that
    % frame.
    p01xy = p01*rotmat;
    q01xy = q01*rotmat;
    
    % Translate everything along Y to put q01xy on the X axis.
    y0 = q01xy(1,2);
    p01xy(:,2) = p01xy(:,2) - y0;
    q01xy(:,2) = q01xy(:,2) - y0;
    
    % At this point we should find that the Z components of p01xy are the
    % same, the Z components of q01xy are the same, and that q01xy(:,2) is
    % zero.
%     check1 = max( abs( p01xy(2,3) - p01xy(1,3) ), abs( q01xy(2,3) - q01xy(1,3) ) );
%     check2 = max( abs( q01xy(:,2) ) );
%     if (check1 > 1e-1) || (check2 > 1e-7)
%         fprintf( 1, '%s: check1 %f ([%f %f, %f %f], check2 %f\n', mfilename(), check1, p01xy(1,3), p01xy(2,3), q01xy(1,3), q01xy(2,3), check2 );
%         xxxx = 1;
%     end
    
    % d2 is the radius of the capsule about q01xy that we must test p01xy
    % against.
    d2 = sqrt( d0^2 - dpq^2 );

    % Henceforth we can ignore the Z components of p01xy and q01xy. We
    % consider these as line segments in the XY plane, and seek the first
    % point of p01xy that reaches a distance d2 from q01xy.
    
    % First, a simple fast check to find some cases of no collision.
    if all( p01xy(:,2) >= d2 ) || all( p01xy(:,2) <= -d2 )
        collision = false;
        collisiontype = 'FAR_INF2';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    dpx = p01xy(2,1) - p01xy(1,1);
    dpy = p01xy(2,2) - p01xy(1,2);
    dpp = sqrt( dpx^2 + dpy^2 );
    dqx = q01xy(2,1) - q01xy(1,1);
    
    % Intersection of p01xy with upper line y = d2.
    pb1 = (d2 - p01xy(1,2))/dpy;
    px1 = [1-pb1 pb1]*p01xy(:,1);
    qb1 = (px1-q01xy(1,1))/dqx;
    
    % Intersection of p01xy with lower line y = -d2.
    pb2 = (-d2 - p01xy(1,2))/dpy;
    px2 = [1-pb2 pb2]*p01xy(:,1);
    qb2 = (px2-q01xy(1,1))/dqx;
    
    % Intersections of p01xy with a circle of radius d2 about q0.
    [dq0,ppq0,bcq0] = pointLineDistance( p01xy, q01xy(1,:), true );
    if dq0 < d2
        dpb3 = sqrt( d2^2 - dq0^2 )/abs(dpp);
        pb3 = bcq0(2) - dpb3;
        qb3 = 0;
    else
        pb3 = Inf;
        qb3 = 0;
    end
    
    % Intersections of p01xy with a circle of radius d2 about q1.
    [dq1,ppq1,bcq1] = pointLineDistance( p01xy, q01xy(2,:), true );
    if dq1 < d2
        dpb4 = sqrt( d2^2 - dq1^2 )/abs(dpp);
        pb4 = bcq1(2) - dpb4;
        qb4 = 1;
    else
        pb4 = Inf;
        qb4 = 1;
    end
    
    % We have up to 4 possible contact points on p01xy, described by their
    % second barycentric coordinates.
    pcontacts = [ pb1, pb2, pb3, pb4 ];
    qcontacts = [ qb1, qb2, qb3, qb4 ];
    
    % Exclude all contacts outside either line segment.
    invalidcontacts = (pcontacts < 0) | (pcontacts > 1) | (qcontacts < 0) | (qcontacts > 1);
    pcontacts( invalidcontacts ) = Inf;
    
    % Find the first contact.
    [pb,ci] = min( pcontacts );
    pbc1 = [1-pb,pb];
    qb = qcontacts( ci );
    qbc1 = [1-qb,qb];
    ppt = pbc1 * p01;
    qpt = qbc1 * q01;
    d = norm( qpt - ppt );
    
    if isinf(pb)
        % No contact.
        collision = false;
        collisiontype = 'FAR_INF3';
        if VERBOSE, fprintf( 1, 'Collision %d, %s\n', collision, collisiontype ); end
        return;
    end
    
    collision = true;
    
    if pb <= 0
        pcollision = 'PBEGIN';
    elseif pb >= 1
        pcollision = 'PEND';
    else
        pcollision = 'PMID';
    end
    
    switch ci
        case { 1, 2 }
            qcollision = 'QMID';
            [dcheck,~,qbccheck] = pointLineDistance( q01, ppt, true );
        case 3
            qcollision = 'QBEGIN';
            qpt = q01(1,:);
            dcheck = norm( qpt - ppt );
            qbccheck = [1 0];
        case 4
            qcollision = 'QEND';
            qpt = q01(2,:);
            dcheck = norm( qpt - ppt );
            qbccheck = [0 1];
    end
    
    collisiontype = [pcollision '-' qcollision];
    
    % dcheck and qbccheck are calculated as checks. They should be equal (up to
    % rounding error) to d and qbc
    
    checkd = abs(dcheck-d) > 1e-5;
    checkqbc = max(abs(qbccheck-qbc1)) > 1e-5;
    if checkd || checkqbc
        fprintf( 1, '%s: checkd %f, checkqbc %f\n', mfilename(), checkd, checkqbc );
        xxxx = 1;
    end
    
    xxxx = 1;
end