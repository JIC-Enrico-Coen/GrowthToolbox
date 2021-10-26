function [vi1a,vi1b,v1,vi2a,vi2b,v2,direction,dist] = splitPolyShortest( splitpoint, vxs, n )
%[vi1a,vi1b,v1,vi2a,vi2b,v2] = splitPolyShortest( splitpoint, vxs )
%   Find the shortest line through splitpoint cutting the polygon vxs.
%   The results are

    if nargin < 3
        n = [0 0 1];
    end
    if size(splitpoint,2)==2
        splitpoint = [ splitpoint, zeros( size(splitpoint,1), 1 ) ];
    end
    if size(vxs,2)==2
        vxs = [ vxs, zeros( size(vxs,1), 1 ) ];
    end
    [x,y] = makeframe( n );
    numsteps = 12;
    vi1a = 0;
    vi1b = 0;
    v1 = 0;
    vi2a = 0;
    vi2b = 0;
    v2 = 0;
    direction = [0,0,0];
    dist = inf;
    for i=0:(numsteps-1)
        a = i*pi/numsteps;
        d = x*cos(a) + y*sin(a);
        [xvi1a,xvi1b,xv1,xvi2a,xvi2b,xv2] = splitPoly( d, splitpoint, vxs );
        dist1 = norm( xv2-xv1 );
        if dist1 < dist
            dist = dist1;
            vi1a = xvi1a;
            vi1b = xvi1b;
            v1 = xv1;
            vi2a = xvi2a;
            vi2b = xvi2b;
            v2 = xv2;
            direction = d;
        end
    end
end
