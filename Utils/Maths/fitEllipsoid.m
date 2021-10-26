function [eigvecs,eigvalues] = fitEllipsoid( pts )
%[eigvecs,eigvalues] = fitEllipsoid( pts )
%   Find the best-fit ellipsoid to a set of points.
%   PTS is an N*D array of N points in D-dimensional space.
%   The result will be a D*D matrix of eigenvectors and a 1*D matrix of
%   eigenvalues.

    numpts = size(pts,1);
    avpt = sum(pts,1)/numpts;
    pts = pts - repmat( avpt,numpts,1);

    [eigvecs,eigvalues] = eig( (pts'*pts)/numpts );
    eigvalues = diag(eigvalues);
    [eigvalues,p] = sort(eigvalues,'descend');
    eigvecs = eigvecs(:,p);
    eigvalues = reshape(eigvalues,1,[]);
end
