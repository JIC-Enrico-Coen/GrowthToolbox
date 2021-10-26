function s = smoothSurface( s, n )
%s = smoothSurface( s, n )
%   Given a surface S as returned by isosurface(), smooth it by averaging
%   each point with its neighbours, N times.  N defaults to 1.

    if nargin < 2
        n = 1;
    end

    nb = surfaceNeighbours( s );
    newv = s.vertices;
    minbb = min( s.vertices, [], 1 );
    sizebb = max( s.vertices, [], 1 ) - minbb;
    numv = size(s.vertices,1);
    for r=1:n
        for i=1:numv
            nbi = nb{i};
            newv(i,:) = sum( newv(nbi,:), 1 )/length(nbi);
        end
        newminbb = min( newv, [], 1 );
        newsizebb = max( newv, [], 1 ) - newminbb;
        for i=1:size(s.vertices,2)
            newv(:,i) = ( newv(:,i) - newminbb(i) ) * (sizebb(i)/newsizebb(i)) + minbb(1,i);
        end
    end
    s.vertices = newv;
end
