function subpts = sparsifyPoints( pts, distance )
%subpts = sparsifyPoints( pts, distance )
%   Given a set of points as an N*D matrix, and a distance, choose a
%   maximal subset of the points such that no two members of the subset are
%   within a distance of not more than distance.  The indexes of the
%   selected points are returned in a column vector.
%
%   If distance is zero, points with identical coordinates will be deemed
%   to be too close.  Thus setting distance=0 amounts to striking out all
%   exact duplicates.  If distance is negative, 1:size(pts,1) is returned
%   immediately.

    numpts = size(pts,1);
    if distance<0
        subpts = 1:size(pts,1);
        return;
    end
    dims = size(pts,2);
    dsq = distance*distance;
    far = false(numpts,numpts);
    for i=1:numpts
        dsqs = (pts(:,1)-pts(i,1)).^2;
        for d=2:dims
            dsqs = dsqs + (pts(:,d)-pts(i,d)).^2;
        end
        far(:,i) = dsqs > dsq;
    end

    subpts = zeros(numpts,1);
    numselected = 0;
    for pi=1:numpts
      % if farfrom( pts(subpts(1:numselected),:), pts(pi,:), dsq )
      % The above is 100 times as slow when numpts==1000.
        if all(far(subpts(1:numselected),pi))
            numselected = numselected+1;
            subpts(numselected) = pi;
        end
    end
    subpts((numselected+1):end) = [];
end

function isfar = farfrom( pts, p, dsq )
% An "optimisation" that slowed the program down by 100.

    if isempty(pts)
        isfar = true;
        return;
    end
    numpts = size(pts,1);
    dims = size(pts,2);
    for i=1:numpts
        dsqs = (pts(:,1)-p(1)).^2;
        for d=2:dims
            dsqs = dsqs + (pts(:,d)-p(d)).^2;
        end
        far = dsqs > dsq;
    end
    isfar = all(far);
end
