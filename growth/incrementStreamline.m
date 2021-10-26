function [nextci, nextbc1, nextbc, newv] = incrementStreamline( m, s ) % downstream, ci, bc )
%[nextci, nextbc1, nextbc, newv] = incrementStreamline( m, downstream, ci, bc )
%   Extend a streamline from the point specified by barycentric coordinates
%   BC in finite element CI, until it hits an edge of that element. The
%   direction is the polariser gradient, either downstream or upstream.
%
%   The result is a pair of points that are contained in the same finite
%   element.  NEXTCI is the index of the FE.  NEXTBC1 is the barycentric
%   coordinates of the point originally specified by CI and BC, but now
%   relative to the vertexes of the element NEXTCI.  NEXTBC is the
%   barycentric coordinates, relative to NEXTCI, of the new point to be
%   added to the streamline.  NEWV is the 3D coordinates of the new point.

    downstream = s.downstream;
    ci = s.vxcellindex(end);
    bc = s.barycoords(end,:);

    directionGlobal = normalisedGradient( m, ci, downstream );
    if all(directionGlobal==0)
        % No direction.  Streamline cannot be continued.
        return;
    end
    
    v = bc * m.nodes( m.tricellvxs(ci,:), : );
    nextbc1 = [];
    nextci = [];
    nextbc = [];
    newv = [];
                           
                            
    % Avoid points that are extremely close to an edge or a vertex.
    CLOSE = 1e-4;
    bc = snapbc( bc, CLOSE );
    
    if any(bc < 0) || any(bc > 1)
        % Invalid coordinates.  Streamline cannot be continued.
        return;
    end

    if abs(sum(bc) - 1) > CLOSE
        % Invalid coordinates.  Streamline cannot be continued.
        return;
    end

    numzeros = sum(bc==0);
    isedge = numzeros==1;
    isvertex = numzeros==2;
    
    if isedge
        % Find the gradient in both cells.
        cei = find(bc==0);
        cei2 = mod(cei,3)+1;
        cei3 = mod(cei+1,3)+1;
        ei = m.celledges(ci,cei);
        cc = m.edgecells(ei,:);
        cn = m.unitcellnormals(ci,:);
        edgevec = m.nodes( m.tricellvxs(ci,cei3), : ) ...
                  - m.nodes( m.tricellvxs(ci,cei2), : );
        into_ci = det( [ cn; edgevec; directionGlobal ] ) >= 0;
        
        
        otherci = cc(cc ~= ci);
        if otherci ~= 0
            g1 = normalisedGradient( m, otherci, downstream );
            cn1 = m.unitcellnormals(otherci,:);
            into_ci1 = det( [ cn1; edgevec; g1 ] ) <= 0;
            if into_ci==into_ci1
                dg = dot( edgevec, directionGlobal );
                dg1 = dot( edgevec, g1 );
                use_g = abs(dg) >= abs(dg1);
                if use_g
                    forwards = dg >= 0;
                else
                    forwards = dg1 >= 0;
                end
                % Follow edge.
                if forwards
                    cvi = cei3;
                else
                    cvi = cei2;
                end
                nextci = ci;
                nextbc1 = bc;
                nextbc = [0 0 0];
                nextbc(cvi) = 1;
            else
                if into_ci
                    nextci = ci;
                    nextbc1 = bc;
                    nextcei = cei;
                else
                    % Continue into ci1.
                    nextci = otherci;
                    nextcei = find( m.celledges(nextci,:)==m.celledges(ci,cei) );
                    nextbc1 = [0 0 0];
                    v1 = m.edgeends(ei,1);
                    v2 = m.edgeends(ei,2);
                    nextbc1( m.tricellvxs(nextci,:)==v1 ) = bc( m.tricellvxs(ci,:)==v1 );
                    nextbc1( m.tricellvxs(nextci,:)==v2 ) = bc( m.tricellvxs(ci,:)==v2 );
                end
                nextbc = continueFromEdge( m, nextci, nextcei, v, g1 );
            end
        elseif into_ci
            % Good
            nextci = ci;
            nextbc1 = bc;
            nextcei = cei;
            nextbc = continueFromEdge( m, nextci, nextcei, v, directionGlobal );
        else
            % No continuation.
        end
    elseif isvertex
        cvi = find(bc > 0,1);
        vi = m.tricellvxs(ci,cvi);
        [nextci,nextei] = propagateThroughVertex( m, downstream, ci, vi, directionGlobal );
        if nextci ~= 0
            nextbc1 = [0 0 0];
            nextbc1( m.tricellvxs(nextci,:)==vi ) = 1;
        end
        if nextei ~= 0
            % Continue along this edge.
            nextvi = m.edgeends(nextei, m.edgeends(nextei,:) ~= vi );
            nextbc = [0 0 0];
            nextbc( m.tricellvxs(nextci,:)==nextvi ) = 1;
        elseif nextci ~= 0
            cvi = m.tricellvxs(nextci,:)==vi;
            cvi1 = find(cvi);
            cvi2 = mod(cvi1,3)+1;
            cvi3 = mod(cvi2,3)+1;
            vi2 = m.tricellvxs(nextci,cvi2);
            vi3 = m.tricellvxs(nextci,cvi3);
            % Propagate direction to opposite edge.
            directionGlobal = normalisedGradient( m, nextci, downstream );
            [a,b,p,q] = simpleLineIntersection( v, ...
                                                v+directionGlobal, ...
                                                m.nodes(vi2,:), ...
                                                m.nodes(vi3,:) );
            if (b<0) || (b>1)
                warning( 'Inconsistent attempt to propagate streamline through vertex %d.', ci );
                return;
            else
                nextbc(cvi) = 0;
                nextbc(cvi2) = 1-b;
                nextbc(cvi3) = b;
            end
        else
            % Streamline cannot be continued.
        end
    elseif all(bc>0)
        % eis = m.celledges( ci, : );
        a = -ones(1,3);
        b = -ones(1,3);
        q = zeros(3,3);
        for i=1:3
            % ei = eis(i);
            vi1 = mod(i,3)+1;
            vi2 = mod(i+1,3)+1;
            [a(i),b(i),p,q(i,:)] = simpleLineIntersection( ...
                v, v+directionGlobal, ...
                m.nodes(m.tricellvxs(ci,vi1),:), ...
                m.nodes(m.tricellvxs(ci,vi2),:) );
        end
        cei = find( (b>=0) & (b <= 1) & (a > 0) );
        if length(cei) > 1
            cei = cei(1);
        end
        nextci = ci;
        nextbc1 = bc;
        nextbc = [0 0 0];
        nextbc( mod(cei,3)+1 ) = 1-b(cei);
        nextbc( mod(cei+1,3)+1 ) = b(cei);
    else
        % Error.
    end
    if ~isempty(nextci)
        newv = nextbc * m.nodes( m.tricellvxs(nextci,:), : );
    end
end

function nextbc = continueFromEdge( m, ci, cei, v, g )
    cei2 = mod(cei,3)+1;
    cei3 = mod(cei+1,3)+1;
    vi1 = m.tricellvxs( ci, cei );
    vi2 = m.tricellvxs( ci, cei2 );
    vi3 = m.tricellvxs( ci, cei3 );
    [a2,b2,p2,q2] = simpleLineIntersection( ...
            v, v+g, m.nodes(vi1,:), m.nodes(vi2,:) );
    [a3,b3,p3,q3] = simpleLineIntersection( ...
            v, v+g, m.nodes(vi1,:), m.nodes(vi3,:) );
    side2 = (a2>0) && (0 <= b2) && (b2 <= 1);
    side3 = (a3>0) && (0 <= b3) && (b3 <= 1);
    if side2 == side3
        % Error?
        xxxx = 0;
    end
    nextbc = [0 0 0];
    if side2
        nextbc(cei2) = b2;
        nextbc(cei) = 1 - b2;
    else
        nextbc(cei3) = b3;
        nextbc(cei) = 1 - b3;
    end
end

function g = normalisedGradient( m, ci, downstream )
    g = m.gradpolgrowth( ci, : );
    if ~downstream
        g = -g;
    end
    if any(g ~= 0)
        g = g * (norm( m.nodes(m.tricellvxs(ci,1),:) - m.nodes(m.tricellvxs(ci,2),:) )/norm(g));
    end
end

function [nextci,nextei] = propagateThroughVertex( m, downstream, ci, vi, g )
    MAXSTREAMLINEBEND = pi/2;

    % Get the data for cells and edges around the node.
    nce = m.nodecelledges{ vi };
    eis = nce(1,:);
    cis = nce(2,:);
    border = cis(end)==0;
    numcells = length(eis);

    % Find the vertex normal and define a frame of reference in the
    % perpendicular frame.  Construct the rotation matrix to transform
    % vectors into that plane.
    ucns = m.unitcellnormals(cis(cis ~= 0),:);
    vxn = sum(ucns,1);
    vxn = vxn/norm(vxn);
    [x,y] = makeframe( vxn );
    rotmat = [x;y]';
    
    % Find the edge vectors and their directions.
    allendvxs = m.edgeends(eis,:)';
    allendvxs = allendvxs(:);
    allendvxs = allendvxs(allendvxs~=vi);
    edgedirs = m.nodes(allendvxs,:) - repmat(m.nodes(vi,:),length(allendvxs),1);
    xyedgedirs = edgedirs*rotmat;
    edgeangles = atan2( xyedgedirs(:,2), xyedgedirs(:,1) );
    
    % Find the gradient vectors and their directions.
    grads = zeros(length(cis),3);
    grads(cis~=0,:) = m.gradpolgrowth(cis(cis~=0),:);
    xygrads = grads*rotmat;
    if ~downstream
        xygrads = -xygrads;
    end
    gradangles = atan2( xygrads(:,2), xygrads(:,1) );
%     if border
%         gradangles = [ gradangles; 0 ];
%     end
    
    
    % Classify the gradient angles as 0 (if they point into their cell), 1
    % (if they point forwards of the cell), or -1 (if they point backwards
    % from their cell).
    de = normaliseAngle( edgeangles([2:end 1]) - edgeangles, -pi, false );
    dg1 = normaliseAngle( gradangles - edgeangles, -pi, false );
    dg2 = normaliseAngle( edgeangles([2:end 1]) - gradangles, -pi, false );
    semiexternal = pi-de/2;
    gtype = zeros(size(gradangles));
    gtype( (dg2 < 0) & (-dg2 <= semiexternal) ) = 1;
    gtype( (dg1 < 0) & (-dg1 < semiexternal) ) = -1;
    if border
        gtype(end) = -2;
    end
    iscandidategrad = gtype==0;
    iscandidateedge = (gtype([end 1:(end-1)]) == 1) & (gtype == -1);
    incomingdir = g*rotmat;
    incomingangle = atan2( incomingdir(2), incomingdir(1) );
    deviations = [ gradangles(iscandidategrad); edgeangles(iscandidateedge) ] - incomingangle;
    [mindev,mindevi] = min(abs(deviations));
    if mindev > MAXSTREAMLINEBEND
        nextci = [];
        nextei = [];
    elseif mindevi <= sum(iscandidategrad)
        % candidate is a cell
        ciis = find(iscandidategrad);
        nextci = cis(ciis(mindevi));
        nextei = 0;
    else
        % Candidate is an edge
        % Check gradient deviations?
        eiis = find(iscandidateedge);
        ncei = eiis(mindevi-sum(iscandidategrad));
        nextei = eis(ncei);
        nextci = cis(ncei);
    end
end

function nextci = propagateThroughVertex1( m, ci, vi, g )
% g points through vertex vi of element ci.
% Find the element it enters.
% This assumes that g points from within element ci.  We need it to work
% without that assumption.

% This is untested and may contain some off-by-one errors.

    nce = m.nodecelledges{ vi };
    eis = nce(1,:);
    cis = nce(2,:);

    ucns = m.unitcellnormals(cis(cis ~= 0),:);
    vxn = sum(ucns,1);
    vxn = vxn/norm(vxn);
    [x,y] = makeframe( vxn );
    
    % Find all of the edge vectors.
    allendvxs = m.edgeends(eis,:)';
    allendvxs = allendvxs(:);
    allendvxs = allendvxs(allendvxs~=vi);
    directions = m.nodes(allendvxs,:) - repmat(m.nodes(vi,:),length(allendvxs),1);

    % Project all edge vectors onto plane perp to 
    rotmat = [x;y]';
    xydirs = directions*rotmat;
    angles = atan2(xydirs(:,2),xydirs(:,1));
    gxydir = g*rotmat;
    angleg = atan2(gxydir(2),gxydir(1));
    
    grads = m.gradpolgrowth(cis(cis~=0),:);
    xygrads = grads*rotmat;
    gradangles = atan2( xygrads(:,2), xygrads(:,1) );
    allowedgrads = (gradangles >= angles) & (gradangles <= angles([2:end 1]));
    gradin = cyclicAngles( [ gradangles, angles, angles([2:end 1]) ] );
    
    % = WORK IN PROGRESS
    
    
    ss = angles < angleg;
    ss & ~ss([2:end 1])
    smaller = find( ss & ~ss([2:end 1]), 1 );
    if smaller==length(angles)
        larger = 1;
    else
        larger = smaller+1;
    end
    nextci = cis(smaller);
end
