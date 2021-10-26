function d = pointPointDistance( p0, p1 )
%d = pointPointDistance( p0, p1 )
%   Return the distances between corresponding members of the N*K arrays p0
%   and p1 of N K-dimensional points.
%   Either p0 or p1 can be a single point, in which case its distance from
%   all the points in the other set will be calculated.

    if size(p0,1)==1
        d = sqrt(sum( (repmat(p0, size(p1,1), 1) - p1).^2, 2 ) );
    elseif size(p1,1)==1
        d = sqrt(sum( (p0 - repmat(p1, size(p0,1), 1)).^2, 2 ) );
    else
        d = sqrt(sum( (p0 - p1).^2, 2 ) );
    end
end
