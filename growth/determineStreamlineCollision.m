function [collidedwith,collidedseg,collidedsegbc,collidersegbc,collisiontype,collisionangle,iscross,collisionparallel] = determineStreamlineCollision( m, ci, p01, radius, noncolliders )
%[collidedwith,collidedseg,collidedsegbc,collidersegbc,collisiontype,collisionangle,iscross,collisionparallel] = determineStreamlineCollision( m, ci, p01, radius, noncolliders )
%
%   Arguments:
%
%   m is a mesh.
%
%   ci is the index of a finite element of the mesh.
%
%   p01 is a 2x3 array containing the global coordinates of two points that
%   lie in the given finite element. These are the endpoints of a segment
%   of a microtubule.
%
%   radius is the thickness of the microtubule.
%
%   noncolliders is a list of microtubules that this segment is deemed not
%   to collide with. Typically this is just the mt that the given segment
%   belongs to.
%
%
%   Results:
%
%   collidedwith is the indexes of all the microtubules it collides with,
%   in increasing order of distance travelled.
%
%   collideseg is the index of the segment of the collider that it collides
%   with.
%
%   segbc is the barycentric coordinates of the collision point within that
%   segment.
%
%   collisiontype is the type of collision. See capsuleApproachToDistance()
%   for a description of the values it can take.
%
%   collisionangle is the angle of the collision (NaN when there is no
%   collision). This is the angle by which the mt would have to bend to
%   become parallel or antiparallel to the other tubule. It is always in
%   the range -pi/2 ... pi/2.
%
%   iscross distinguishes two sorts of collision. When true, the
%   corresponding collision represents one tubule crossing over the other:
%   their spines intersect. When false, one tubule touched the other: their
%   spines approached to within a tubule diameter. Unless the two tubules
%   start out with the head of the growing one already closer than the
%   tubule diameter, these events will occur in pairs: a touch followed by
%   a crossing.

    INITSIZE = 10;
    collidedwith = zeros(1,INITSIZE);
    collidedseg = zeros(1,INITSIZE);
    collidedsegbc = zeros(INITSIZE,2);
    collidersegbc = zeros(INITSIZE,2);
    collisiontype = cell(1,INITSIZE);
    collisionangle = zeros(1,INITSIZE);
    collisionparallel = false(1,INITSIZE);
    iscross = false(1,INITSIZE);

    colliders = setdiff( 1:length( m.tubules.tracks ), noncolliders );
    
    elementNormal = m.unitcellnormals(ci,:);
    
    numcollisions = 0;

    allsegcellindex = [m.tubules.tracks(colliders).segcellindex];
    allmtindex = zeros(size(allsegcellindex));
    allsegindex = zeros(size(allsegcellindex));
    a = 1;
    for si=colliders
        b = length(m.tubules.tracks(si).segcellindex);
        allmtindex(a:(a+b-1)) = si;
        allsegindex(a:(a+b-1)) = 1:b;
        a = a+b;
    end
    if ~isempty( allmtindex )
        exclude = [ allmtindex(1:(end-1)) ~= allmtindex(2:end), true ];
        allsegcellindex(exclude) = [];
        allmtindex(exclude) = [];
        allsegindex(exclude) = [];
        exclude = allsegcellindex ~= ci;
        allsegcellindex(exclude) = [];
        allmtindex(exclude) = [];
        allsegindex(exclude) = [];
    end
    
    for ai=1:length(allsegcellindex)
        segi = allsegindex(ai);
        xci = allsegcellindex(ai);
        si = allmtindex(ai);
        s = m.tubules.tracks(si);
        xxxx = 1;
        q01 = s.globalcoords([segi,segi+1],:);
        rawangle = vecangle( p01(2,:) - p01(1,:), q01(2,:) - q01(1,:), elementNormal ); % cangle is in the range -pi .. pi.
        if rawangle < -pi/2
            ispar = false;
            cangle = rawangle + pi;
        elseif rawangle > pi/2
            ispar = false;
            cangle = rawangle - pi;
        else
            ispar = true;
            cangle = rawangle;
        end
        % cangle is now in the range -pi/2 .. pi/2.
        % Rotating p2-p1 about n by collisionangle will make it
        % either parallel or antiparallel to q2-q1.
%             cangle = pi/2 - abs(cangle-pi/2);  % a is in the range 0 .. pi/2.
        [pbc1,qbc1,pbcx,qbcx,d,coll,ctype] = capsuleApproachToDistance2( p01, q01, radius+m.tubules.tubuleparams.headradius );
        [x_pbc_touch,x_pbc_cross,x_qbc_touch,x_qbc_cross] = capsuleApproachToDistance3( p01, q01, radius+m.tubules.tubuleparams.headradius );
        pbc1 = trimbc( pbc1 );
        qbc1 = trimbc( qbc1 );
        pbcx = trimbc( pbcx );
        qbcx = trimbc( qbcx );
        if pbc1(2) > pbcx(2)
            xxxx = 1;
        end
        if coll
            numcollisions = numcollisions+1;
            collidedwith(numcollisions) = si;
            collidedseg(numcollisions) = segi;
            collidedsegbc(numcollisions,:) = qbc1;
            collidersegbc(numcollisions,:) = pbc1;
            collisiontype{numcollisions} = ctype;
            collisionangle(numcollisions) = cangle;
            collisionparallel(numcollisions) = ispar;
            iscross(numcollisions) = false;
        end
        if ~any(isnan(pbcx)) && ~any(isnan(qbcx))
            numcollisions = numcollisions+1;
            collidedwith(numcollisions) = si;
            collidedseg(numcollisions) = segi;
            collidedsegbc(numcollisions,:) = qbcx;
            collidersegbc(numcollisions,:) = pbcx;
            collisiontype{numcollisions} = ctype;
            collisionangle(numcollisions) = cangle;
            collisionparallel(numcollisions) = ispar;
            iscross(numcollisions) = true;
        end
    end
    
    collidedwith( (numcollisions+1):end ) = [];
    collidedseg( (numcollisions+1):end ) = [];
    collidedsegbc( (numcollisions+1):end, : ) = [];
    collidersegbc( (numcollisions+1):end, : ) = [];
    collisiontype( (numcollisions+1):end ) = [];
    collisionangle( (numcollisions+1):end ) = [];
    collisionparallel( (numcollisions+1):end ) = [];
    iscross( (numcollisions+1):end ) = [];
    
    if numcollisions > 1
        [~,collideperm] = sort( collidersegbc(:,2) );
        collidedwith = collidedwith(collideperm);
        collidedseg = collidedseg(collideperm);
        collidedsegbc = collidedsegbc(collideperm,:);
        collidersegbc = collidersegbc(collideperm,:);
        collisiontype = collisiontype(collideperm);
        collisionangle = collisionangle(collideperm);
        collisionparallel = collisionparallel(collideperm);
        iscross = iscross(collideperm);
        xxxx = 1;
    end
    
    if all(collidersegbc(:) ~= 0) && any(collidersegbc(:) < 1e-8)
        xxxx = 1;
    end
    
    % Force the vectors to be column vectors because Matlab one-dimensional
    % arrays are fucked.
    collidedwith = collidedwith(:);
    collidedseg = collidedseg(:);
    collisiontype = collisiontype(:);
    collisionangle = collisionangle(:);
    collisionparallel = collisionparallel(:);
    iscross = iscross(:);
end
