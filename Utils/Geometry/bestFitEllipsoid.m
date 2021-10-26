function [principalAxes,eigs,centre] = bestFitEllipsoid( vxs, wts, origin )
%[principalAxes,eigs] = bestFitEllipsoid( vxs, wts )
%   Find the best-fit ellipsoid containing the vertexes VXS, an N*D array
%   where D is the number of dimensions.  The result is returned as a
%   matrix of column vectors, being the principal axes of the ellipsoid,
%   and a column vector of the eigenvalues.  The eigenvalues are listed
%   in arbitrary order, and are proportional to the squares of the lengths
%   of the ellipsoid's principal axes.
%
%   WTS is an optional parameter specifying a weight for each vertex.  If
%   WTS is absent or empty the weights are taken to be equal.  If WTS is
%   the string 'area' then the members of vxs are assumed to be the
%   vertexes of a polygon, listed in order along its boundary, and the
%   weights will be a measure of the amount of the polygon's circumference
%   associated with each vertex. This makes the results largely independent
%   of how densely the vertexes are distributed around the perimeter of the
%   polygon.
%
%   If ORIGIN is specified, it is a single point, and the ellipse is the
%   best-fitting one conditional on having its centre at that point.

    N = size(vxs,1);
    D = size(vxs,2);
    if (nargin < 2) || isempty(wts) || all(wts==wts(1))
        if nargin > 2
            centre = origin;
        else
            centre = sum(vxs,1)/N;
        end
        m = (vxs' * vxs) / N - centre'*centre;
    else
        if ischar(wts)
            if strcmp( wts, 'area' )
                edgevecs = vxs([2:end 1],:) - vxs;
                edgelengths = sqrt(sum(edgevecs.^2,2));
                wts = (edgelengths + edgelengths([end 1:(end-1)]))/2;
            else
                error( 'Optional WTS argument ''%s'' not recognised. Allowable values are ''area'' or a vector of weights.', ...
                    wts );
            end
        end
        wts = wts/sum(wts);
        wvxs = vxs.*repmat(wts,1,D);
        if nargin > 2
            centre = origin;
        else
            centre = sum(wvxs,1);
        end
        m = (vxs' * wvxs) - centre'*centre;
    end
    if any(isnan(m(:))) || all(m(:)==0)
        principalAxes = nan(size(m));
        eigs = nan(size(m,1),1);
    else
        [principalAxes,eigs] = eig(m);
        eigs = diag(eigs);
        [eigs,perm] = sort(eigs);
        principalAxes = principalAxes(:,perm);
    end
end
