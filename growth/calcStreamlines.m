function [m,streamlines] = calcStreamlines( m )
%[m,s] = calcStreamlines( m )
%   Calculate streamlines of the polariser gradient of m.
%
%   OBSOLETE: PROBABLY DOES NOT WORK.

    MIN_STREAM_DIST = 0.1;

    % Streamlines will join points placed on the edges of m.
    
    % The current status of an edge will be one of:
    %   0: undecided (the initial state of all edges)
    %   -1: no streamline passes through this edge
    %   positive: the index of the streamline this edge belongs to.
    edgestatus = zeros( size(m.edgeends,1), 1 );
    
    streamlines = zeros(0,6);
    streamindex = 0;
    edgeorder = randperm(length(edgestatus));
    
    
    for eii=1:length(edgestatus)
        ei = edgeorder(eii);
        if edgestatus(ei) ~= 0
            % Status already decided.
            continue;
        end
        v1 = m.nodes(m.edgeends(ei,1),:);
        v2 = m.nodes(m.edgeends(ei,2),:);
        v = (v1+v2)/2;
        if closeTo( v, streamlines(:,[3 4 5]), MIN_STREAM_DIST*1.25 )
            % This edge is too close to an existing streamline.
            % Mark it as not belonging to any streamline.
            edgestatus(ei) = -1;
            continue;
        end
        [s,edgestatus] = makestreamline( m, edgestatus, ei, 0.5, v, [], streamlines, MIN_STREAM_DIST );
        if ~isempty(s)
            streamindex = streamindex+1;
            streamlines = [ streamlines; [ s, streamindex*ones(size(s,1),1) ] ];
        end
    end
end

function isnear = closeTo( v, vs, mindist )
% Return true iff point v is closer than mindist to at least one point in
% vs.
    diffs = vs - repmat( v, size(vs,1), 1 );
    near = all( diffs < mindist, 2 );
    isnear = any( sum( diffs(near,:).^2, 2 ) < mindist^2 );
%     alldists = sqrt( sum( diffs.^2, 2 ) )';
%     isnear2 = any(alldists < mindist );
%     find(alldists < mindist)
%     if isnear ~= isnear2
%         xx = 1;
%     end
end

function [s,edgestatus] = makestreamline( m, edgestatus, ei, w, v, up, streamlines, mindist )
    ei0 = ei;
    v0 = v;
    ci = m.edgecells(ei,1);
    s = [ei,w,v];
    while true
        [ei,w,v,up] = propagateStreamline( m, ei, v, ci, up, streamlines, mindist );
        if isempty(ei)
            edgestatus(ei) = -1;
            break;
        end
        edgestatus(ei) = 1;
        s(end+1,:) = [double(ei),w,v];
        vcheck = m.nodes(m.edgeends(ei,1),:)*(1-w) + m.nodes(m.edgeends(ei,2),:)*w;
        cis = m.edgecells(ei,:);
        ci = cis(cis~=ci);
    end
    ci = m.edgecells(ei0,2);
    if ci==0
        if size(s,1) <= 1
            edgestatus(s(1,1)) = -1;
            s = zeros(0,3);
        end
        return;
    end
    s = s(end:-1:1,:);
    ei = ei0;
    v = v0;
    if ~isempty(up)
        up = ~up;
    end
    while true
        [ei,w,v,up] = propagateStreamline( m, ei, v, ci, up, streamlines, mindist );
        if isempty(ei)
            edgestatus(ei) = -1;
            break;
        end
        edgestatus(ei) = 1;
        s(end+1,:) = [double(ei),w,v];
        vcheck = m.nodes(m.edgeends(ei,1),:)*(1-w) + m.nodes(m.edgeends(ei,2),:)*w;
    end
    if size(s,1) <= 1
        edgestatus(s(1,1)) = -1;
        s = zeros(0,3);
    end
end

function [nextei,nextwt,nextv,up] = propagateStreamline( m, ei, v, ci, up, streamlines, mindist )

    nextei = [];
    nextwt = [];
    nextv = [];

    if ci==0
        % No element;
        return;
    end
    
    direction = m.gradpolgrowth(ci,:,1);
    if all(direction==0)
        % No gradient.
        return;
    end
    
    cei = find( m.celledges(ci,:)==ei );
    if isempty(cei)
        % Invalid data.
        return;
    end
    
    cei2 = mod(cei,3)+1;
    cei3 = mod(cei2,3)+1;
    ei2 = m.celledges(ci,cei2);
    ei3 = m.celledges(ci,cei3);
    
    % Find intersection of direction with another side of the triangle.
    
    oppvxs2 = m.nodes( m.edgeends(ei2,:), : );
    oppvxs3 = m.nodes( m.edgeends(ei3,:), : );
    [a,b,p,q] = simpleLineIntersection( v, v+direction, oppvxs2(1,:), oppvxs2(2,:) );
    if any(isnan(b)) || any(isinf(b)) || (b<0) || (b>1)
        % No intersection
        [a,b,p,q] = simpleLineIntersection( v, v+direction, oppvxs3(1,:), oppvxs3(2,:) );
        if any(isnan(b)) || any(isinf(b)) || (b<0) || (b>1)
            % No intersection
            return;
        end
        eicandidate = ei3;
    else
        eicandidate = ei2;
    end
    
    isup = a > 0;

    if (nargin < 5) || isempty(up)
        up = isup;
    elseif up ~= isup
        % Wrong direction.
        return;
    end
    
    if closeTo( q, streamlines(:,[3 4 5]), mindist )
        return;
    end

    % We have found the next vertex.
    nextei = eicandidate;
    nextwt = b;
    nextv = q;
end

