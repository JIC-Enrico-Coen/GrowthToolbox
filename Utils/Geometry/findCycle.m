function [cycle,edgeperm] = findCycle( v )
%cycle = findCycle( v )
%   v is an n*2 matrix of vertex indexes, which represents the set of edges
%   of a polygon.  cycle is a list of the vertexes in order round the polygon.
%   Since there is no geometrical information present, it is not possible
%   to determine whether the ordering is clockwise or anticlockwise
%   (indeed, the polygon need not be planar).
%   This procedure assumes the data are valid and makes no checks.
%   perm is the permutation such that cycle = perm(v(:,1)).

%   This needs to be updated to cope with the situation where the polygon
%   contains multiple connected components.  When assembling the final
%   cycle, we need to test for hitting the first vertex, then scan through
%   v1 to start another cycle.
%
%   It also needs to handle the situation where the edges do not form a
%   cycle.

    numedges = size(v,1); % This is also the number of vertexes.
    if numedges==0
        cycle = [];
        edgeperm = [];
        return;
    end
    
    % Renumber the vertex indexes to 1:numedges.
    fromIndex = zeros(1,max(max(v)));
    toIndex = zeros(1,numedges);
    ptsSeen = 0;
    for i=1:numedges
        vv = v(i,1);
        if fromIndex( vv ) == 0
            ptsSeen = ptsSeen+1;
            fromIndex( vv ) = ptsSeen;
            toIndex( ptsSeen ) = vv;
        end
        vv = v(i,2);
        if fromIndex( vv ) == 0
            ptsSeen = ptsSeen+1;
            fromIndex( vv ) = ptsSeen;
            toIndex( ptsSeen ) = vv;
        end
    end
    v1 = reshape( fromIndex( v' ), 2, [] )';

    % Create an occurrence list.  occurrences(k,1:2) contains the two indexes
    % of rows of v1 in which vertex k occurs.
    occurrences = zeros(numedges,2);
    for i=1:numedges
        if occurrences(v1(i,1),1)
            occurrences(v1(i,1),2) = i;
        else
            occurrences(v1(i,1),1) = i;
        end
        if occurrences(v1(i,2),1)
            occurrences(v1(i,2),2) = i;
        else
            occurrences(v1(i,2),1) = i;
        end
    end
    
    % Create the cycle by starting with the two vertexes on an arbitrary edge,
    % and repeatedly taking the other edge that the last vertex lies on, and
    % the other vertex of that edge.
    cycle = zeros(1,numedges);
    edgeperm = zeros(1,numedges);
    prevPt = 1;
    cycle(1) = prevPt;
    e = occurrences( prevPt, 1 );
    edgeperm(1) = e; 
    edgeperm(numedges) = occurrences( prevPt, 2 ); 
    curPt = otherPt( prevPt, v1( e, : ) );
    cycle(2) = curPt;
    for i=3:numedges
        es = occurrences( curPt, : );
        tryedge = es(1);
        nb = otherPt( curPt, v1( tryedge, : ) );
        if nb==prevPt
            tryedge = es(2);
            nb = otherPt( curPt, v1( tryedge, : ) );
        end
        prevPt = curPt;
        curPt = nb;
        edgeperm(i-1) = tryedge;
        cycle(i) = curPt;
    end
    cycle = toIndex( cycle );
  % cycle==edges(edgeperm,1)
  % needswap = cycle==v(edgeperm,2)';
  % v(needswap,:) = v(needswap,[2 1]);
end

function i1 = otherPt( i, jk )
    if i==jk(1)
        i1 = jk(2);
    else
        i1 = jk(1);
    end
end

