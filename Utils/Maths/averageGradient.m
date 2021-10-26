function g = averageGradient( pts, vals )
%g = averageGradient( pts, vals )
%   Given a set of points in N-dimensional space, and a value at each
%   point, compute the best approximation to the gradient vector of that
%   distribution of values.

    centroid = sum(pts,1)/size(pts,1);
    pts = pts - repmat( centroid, size(pts,1),1);
    avval = sum(vals)/length(vals);
    vals = vals - avval;
    ptspts = pts'*pts;
    if cond(ptspts) > 10000
        g = [0 0 0];
    else
        g = ptspts\(vals(:)'*pts)';
    end
end
