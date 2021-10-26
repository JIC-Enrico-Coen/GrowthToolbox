function [c,p,flatness,planarity,v,d] = bestFitPlane( vxs, weights )
%[c,p,flatness] = bestFitPlane( vxs, weights )
%   Find the best-fit plane through the vertexes VXS, an N*D array where D
%   is the number of dimensions.  The result is returned in the form of C,
%   the centroid of the vertexes, and P, the unit normal vector to the plane
%   through C, both as row vectors.  FLATNESS is a measure of how flat the
%   set of points is, and is the ratio of the smallest to second smallest
%   eigenvalue of the covariance matrix.  Zero means very flat, 1 means not
%   at all flat. PLANARITY is a different measure of flatness, the ratio of
%   the smallest eigenvalue to the sum of eigenvalues. It varies betwen 0
%   (absolutely flat) and 1/3 (not at all flat).
%
%   WEIGHTS, if supplied, weights the vertices.  When the weights are
%   integers, this is exactly equivalent to repeating each vertex as many
%   times as its weight. By default all weights are 1.
%
%   If WEIGHTS is 'length', then the best fit plane will be calculated for
%   the circumference of the polygon whose vertexes are vxs, listed in order
%   round the polygon, as if points were sampled at equal distances
%   around the circumference.
%
%   If WEIGHTS is 'area', then the best fit plane will be calculated for
%   the area of the polygon whose vertexes are vxs, listed in order
%   round the polygon, as if points were sampled at equal density over
%   its area. When the polygon is not flat, it is assumed
%   to consist of triangles between each consecutive pair of vertexes and
%   the centroid.
%
%   'area' and 'length' are in fact mathematically equivalent, and the same
%   calculation is made for both.

    N = size(vxs,1);
    if nargin > 1
        if ischar(weights)
            switch weights
                case { 'length', 'area' }
                    c = sum(vxs,1)/N;
                    vxs = vxs - repmat( c, N, 1 );
                    vxs1 = vxs([2:end 1],:);
                    vv1 = vxs'*vxs1;
                    m = (2/3)*(vxs'*vxs) + (1/6)*(vv1+vv1');
            end
        else
            weights = weights/sum(weights);
            c = sum( vxs .* repmat( weights(:), 1, size(vxs,2) ), 1 );
            vxs1 = vxs .* repmat( sqrt(weights(:)), 1, size(vxs,2) );
            m = vxs1' * vxs1 - c'*c;
        end
    else
        c = sum(vxs,1)/N;
        m = (vxs' * vxs) / N - c'*c;
    end
    [v,d] = eig(m);
    [~,perm] = sort( diag(d) );
    d = d(perm,perm);
    v = v(:,perm);
    p = v(:,1)';
    p = p/sqrt(sum(p.*p));
    % Need to flip direction of p if necessary to obey right-hand rule.
    vxsc = vxs - c;
    rhss = dot( repmat( p, N, 1 ), cross( vxs, vxs([2:end,1],:) ) );
    rhs = sum(rhss);
    if rhs<0
        p = -p;
    end
    
    
    
    flatness = abs( d(1,1)/d(3,3) );  % d should always be non-negative,
                                      % but rounding errors can make "zero"
                                      % eigenvalues slightly negative.
    planarity = abs( d(1,1)/sum(diag(d)) );
    d = diag(d);
    return;
    
    figure(1);
    clf
    hold on
    plotpts( gca, vxs, 'ko' );
    plotvecs( gca, c, c+v(:,1)', 'r' );
    axis equal
    view([35,30]);
    hold off
end
