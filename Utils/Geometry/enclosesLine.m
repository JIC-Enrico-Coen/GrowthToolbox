function encloses = enclosesLine( pts, line )
%encloses = enclosesLine( pts, line )
%   Determine whether a given polygon, defined by pts, its vertexes listed
%   in order, encloses a line, given as a 2*3 array of two points.

    numpts = size(pts,1);
    % Convert the line to a unit vector.
    v = line(2,:) - line(1,:);    
    v = v/norm(v);
    newpts = zeros(size(pts));
    % Consider the points relative to the first point on the line,
    % project them to lie perpendicular to the line, and reduce them to
    % unit vectors.
    for i=1:numpts
        p = pts(i,:) - line(1,:);
        c = dot( p, v );
        p = p - c*v;
        newpts(i,:) = p/norm(p);
    end
    % Determine the angle from each point to the next, following the
    % right-hand rule around v.  The sum of these angles if zero if and
    % only if the polygon does not enclose the line.  In general, the sum
    % is a multiple of 2pi, the multiple being the number of times the
    % polygon winds around the line.
    ss = crossproc2( newpts, newpts([2:end, 1],:) );
    cs = dotproc2( newpts, newpts([2:end, 1],:) );
    totalangle = 0;
    for i=1:numpts
        s = dot( v, ss(i,:) );
        if s > 0
            a = atan2( norm(ss(i,:)), cs(i) );
        else
            a = atan2( -norm(ss(i,:)), cs(i) );
        end
        totalangle = totalangle + a;
    end
    encloses = abs(totalangle) > 0.1;
end

