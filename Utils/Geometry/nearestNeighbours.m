function r = nearestNeighbours( p1, p2 )
%r = nearestNeighbours( p1, p2 )
%   For each point in p1, find the point in p2 that is closest.
%   For all i, p2(r(i),:) is the member of p2 that is closest to p1(i,:).

% Algorithm from Mathworks Statistics Toolbox, much faster than mine.
    r = knnsearch( p2, p1 );
    return;

%   Brute force algorithm.

    np1 = size(p1,1);
    np2 = size(p2,1);
    n = zeros(1,np2);
    r = zeros(np1,1);
    for i1=1:np1
        for i2=1:np2
            n(i2) = norm( p1(i1,:) - p2(i2,:) );
        end
        [ignore,r(i1)] = min(n);
    end
end
