function [alledges,dists] = nearneighbours( pts, dist, metric )
%alledges = nearneighbours( pts, dist )
%   A procedure to determine which pairs of points in a set are close to
%   each other.

%   PTS is an N*D array of N points in D-dimensional space.
%   DIST is a positive number.
%   METRIC, if supplied, specifies the metric to use, and is either 'Linf'
%   (maximum distance along any axis) (the default), 'L1' (sum of absolute
%   distances along the axes), or 'L2' (Euclidean distance).
%
%   ALLEDGES will be a K*2 array, where each row lists a pair of points in
%   PTS that are closer to each other than DIST in the chosen metric.
%   DISTS, if requested, in the distances along each edge.

    if nargin < 3
        metric = 'L0';
    end
    
    alledges = nearneighbours1D( pts(:,1), dist );
    for i=2:size(pts,2)
        moreedges = nearneighbours1D( pts(:,i), dist );
        alledges = intersect( alledges, moreedges, 'rows' );
    end
    
    if (nargout >= 2) || (~strcmp(metric,'Linf'))
        diffs = pts(alledges(:,2),:) - pts(alledges(:,1),:);
        switch metric
            case 'L1'
                dists = sum(abs(diffs),2);
                alledges = alledges(dists<dist,:);
            case 'L2'
                dists = sum(diffs.^2,2);
                alledges = alledges(dists<dist.^2,:);
            otherwise
                if nargout >= 2
                    dists = max(abs(diffs),[],2);
                end
        end
    end
    
    
%     plotpts( pts, 'o' );
%     plotlines( alledges, pts );
%     axis equal
end

function pairs = nearneighbours1D( x, dist )
    [x1,p] = sort(x);
    dx = [ x1(2:end)-x1(1:(end-1)); dist*2 ];
    xlo = 1;
    xhi = 1;
    near = zeros(length(x),2);
    nearcount = 0;
    
    d = 0;
    while xlo <= length(x)
        while d < dist
            d = d + dx(xhi);
            xhi = xhi+1;
        end
        if xhi-1 > xlo
            nearcount= nearcount+1;
            near(nearcount,:) = [xlo,xhi-1];
        end
        while d > dist
            d = d - dx(xlo);
            xlo = xlo+1;
        end
    end
    near((nearcount+1):end,:) = [];
    numnbs = near(:,2)-near(:,1);
    totalnbs = sum(numnbs.*(numnbs+1))/2;
    pairs = zeros(totalnbs,2);
    pi = 0;
    for i=1:size(near,1)
        n = numnbs(i);
        for j=0:n
            for k=(j+1):n
                pi = pi+1;
                pairs(pi,:) = near(i,1)+[j,k];
            end
        end
    end
    pairs = reshape( p(pairs(:)), size(pairs) );
    pairs = sort( pairs, 2 );
end
