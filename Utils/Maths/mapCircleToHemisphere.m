function hemispherePts = mapCircleToHemisphere( circPts, zorigin )
%hemispherePts = mapCircleToHemisphere( circPts )
%   circPts is an N*2 array of N points within the unit circle.
%   hemispherePts will be an N*3 array in which each point is projected
%   onto the hemisphere with the same circular border and in +Z half of the
%   space.
%
%   The projection is made from the point [0 0 -zorigin]. The default value
%   of zorigin is 1. The sign of zorigin is ignored. If zorigin is zero,
%   all points will be projected to the circumference of the init circle,
%   except that [0 0], if present, is projected to [0 0 1].
%
%   Using 'uniform' as the value of zorigin sets it to 2.148. This gives a
%   mapping whose scaling of area is equal at the circumference and the
%   centre of the circle. Precisely, this value is a root of the polynomial
%   z^3 - z^2 - 2z - 1 = 0. This does not give a uniform mapping of areas,
%   but it is fairly close to that.


    if nargin < 2
        zorigin = 1;
    end
    if ischar(zorigin)
        if strcmpi(zorigin,'uniform')
            zorigin = 2.148;
        else
            hemispherePts = [];
            return;
        end
    end
    zorigin = abs(zorigin);
    rsq = sum( circPts.^2, 2 );
    r = sqrt(rsq);
    if zorigin==1
        r1 = 2*r./(1+rsq);
    elseif zorigin==0
        r1 = ones(size(r));
    elseif isinf(zorigin)
        r1 = r;
    else
        zosq = zorigin^2;
        r1 = r.*(zosq + sqrt( rsq + zosq.*(1-rsq) ))./(rsq+zosq);
    end
    z = sqrt(1-r1.^2);
    hemispherePts = [ (r1./r).*circPts, z ];
    zero_r = r==0;
    numz = sum(zero_r);
    hemispherePts(zero_r,:) = repmat( [0 0 1], numz, 1 );
end
