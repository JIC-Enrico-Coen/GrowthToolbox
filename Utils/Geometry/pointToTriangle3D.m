function [p1,bcs,d,nbcs] = pointToTriangle3D( vxs, p )
%[p1,bcs,d,nbcs] = pointToTriangle3D( vxs, p )
%   vxs is a triangle in 3D space defined by the row vectors of its
%   coordinates.  p is a point.
%
%   The results are:
%
%   p1: the point in the triangle that is closest to p
%   bcs: the barycentric coordinates of p1
%   d: the distance of p1 from p
%   nbcs: the barycentric coordinates of the projection of p to the plane
%       of the triangle.  This is the same as bcs if the projection lies
%       within the triangle.

    NVXS = size(vxs,1);
    [p1,nbcs] = projectPointToPlane( vxs, p );
    rightside = nbcs>=0;
    
    if all(rightside)
        % p is within the triangle.
        d = sqrt( sum((p-p1).^2, 2) );
        bcs = nbcs;
    else
        % p is on the wrong side of at least one edge.
        % The closest point must be in one of those edges.
        d1 = Inf;
        for vi=find(~rightside)
            othervi = (1:NVXS)~=vi;
            vxs1 = vxs(othervi,:);
            [p2,bcs2,pbcs2] = projectPointToLine( vxs1, p1, true );
            d = sqrt( sum( (p-p2).^2, 2 ) );
            done = all(pbcs2 >= 0);
            if done || (d < d1)
                bcs = zeros(1,NVXS);
                bcs(othervi) = bcs2;
            end
            if done
                break;
            end
        end
        p1 = p2;
    end
end