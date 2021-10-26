function [p1,bcs,d,pbcs] = pointToTetrahedron( vxs, p )
%[p1,bcs] = pointToTetrahedron( p, vxs )
%   p is a 1*3 vector defining a point in 3D space.  vxs is a 4*3 matrix
%   defining the 4 vertexes of a tetrahedron.
%
%   p1 is the closest point in that tetrahedron to p.
%   bcs is the barycentric coordinates of p1.
%   d is the distance of p1 from p.
%   pbcs is the barycentric coordinates of p.  d==0 if and only if pbcs==bcs.
%
%   See also: pointToTriangle3D

%   In principle, this procedure could be generalised to any simplex.

%     DIMS = size(vxs,2);
    NVXS = size(vxs,1);

    % Find the barycentric coordinates of p relative to vxs.
    pbcs = [p 1]/[vxs,ones(NVXS,1)];
    rightside = pbcs >= 0;
    
    if all(rightside)
        % p is within the tetrahedron.
        p1 = p;
        bcs = pbcs;
        d = 0;
    else
        % p is on the wrong side of at least one face.
        % The closest point must be in one of those faces.
        d1 = Inf;
        for vi=find( ~rightside )
            othervi = (1:NVXS)~=vi;
            vxs1 = vxs(othervi,:);
            [p1a,p1bcs,d,nbcs] = pointToTriangle3D( vxs1, p );
            rightside2 = nbcs>=0;
            done = all(rightside2);
            if done || (d < d1)
                p1 = p1a;
                bcs = zeros(1,NVXS);
                bcs(othervi) = p1bcs;
                if done
                    % p1 lies within the face, and must be the closest point to p.
                    break;
                end
                d1 = d;
            end
        end
    end
    
    err = max(abs(p1 - bcs*vxs));
    if err > 1e-6
        xxxx = 1;
    end
end

