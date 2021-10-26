function p = projectPointToPlane2( point, normal, distance, ratio )
%p = projectPointToPlane2( point, normal, distance )
%   Project POINT to the plane normal to NORMAL at DISTANCE from the origin.
%p = projectPointToPlane2( point, normal, through )
%   Project POINT to the plane normal to NORMAL that passes through the
%   point THROUGH.
%   NORMAL must be nonzero, but does not have to be a unit vector.
%   POINT can be an N*D matrix of D-dimensional points.
%   If RATIO is supplied, the points will not be moved the full distance to
%   the plane, but only the given proportion of the distance.  Thus RATIO=1
%   gives full flattening, RATIO=0 gives no change.

    if nargin < 3
        distance = 0;
    end
    if nargin < 4
        ratio = 1;
    end
    if numel(distance) > 1
        distance = sum(distance.*normal);
    end
    normsq = sum(normal.*normal);
    numpts = size(point,1);
    dims = size(point,2);
    pn = zeros(numpts,dims);
    for i=1:dims
        pn(:,i) = point(:,i)*normal(i);
    end
    k = (distance - sum(pn,2))/normsq;
    p = point + (k*normal)*ratio;
end
