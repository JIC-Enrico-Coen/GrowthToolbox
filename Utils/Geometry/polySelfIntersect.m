function intersections = polySelfIntersect( pts )
%polySelfIntersect( pts )
%   PTS is the set of vertexes of a polygon in the plane, listed in
%   anticlockwise order.  The result is a list of self-intersections.  Each
%   row contains 4 elements: [A,B,C,D] means that the edge from A to B
%   intersects the edge from C to D.

    % Brute force: test every edge against every other edge.
    numpts = size(pts,1);
    numscts = 0;
    intersections = zeros(0,4);
    maxstep = floor(numpts/2);
    extrastep= 0;
    if maxstep==numpts/2
        maxstep = maxstep-1;
        extrastep = numpts/2;
    end
    for i=1:numpts
        j = mod(i,numpts)+1;
        for k=2:maxstep
            i1 = i+k;
            if i1 > numpts
                i1 = i1 - numpts;
            end
            j1 = mod(i1,numpts)+1;
            x = linesIntersect( pts(i,:), pts(j,:), pts(i1,:), pts(j1,:) );
            if x
                numscts = numscts+1;
                intersections(numscts,:) = [ i, j, i1, j1 ];
            end
        end
    end
    if extrastep > 0
        for i=1:extrastep
            j = i+1;
            i1 = i+extrastep;
            j1 = mod(i1,numpts)+1;
            x = linesIntersect( pts(i,:), pts(j,:), pts(i1,:), pts(j1,:) );
            if x
                numscts = numscts+1;
                intersections(numscts,:) = [ i, j, i1, j1 ];
            end
        end
    end
end

function x = linesIntersect( v1, v2, v3, v4 )
    v21 = v2-v1;
    v31 = v3-v1;
    v41 = v4-v1;
    d213 = v31(1)*v21(2)-v31(2)*v21(1) > 0;
    d214 = v41(1)*v21(2)-v41(2)*v21(1) > 0;
    if d213==d214
        x = false;
        return;
    end
    v43 = v4-v3;
    v13 = -v31;
    v23 = v2-v3;
    d431 = v13(1)*v43(2)-v13(2)*v43(1) > 0;
    d432 = v23(1)*v43(2)-v23(2)*v43(1) > 0;
    x = d431 ~= d432;
end
 