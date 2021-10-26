function [pp,bc] = projectPointToPlane( vxs, p, dir )
%pp = projectPointToPlane( vxs, p, dir )
%   Project P in direction DIR onto the plane defined by the three vertexes
%   VXS, giving point PP.  VXS is a 3*D matrix of three row vectors of any
%   dimensionality D.  If the three points are collinear, then P is projected
%   onto the line they define.  N can be of any non-zero length.  It
%   defaults to a vector normal to the plane.
%   BC is set to the barycentric coordinates of the projected point with
%   respect to VXS, as a 1*D row vector.  The equality PP == BCS*VXS
%   holds.  When the three points are collinear, the third component of BC
%   is always zero.  P may be an K*D matrix of row vectors for any K.

    if (nargin < 3) || isempty(n)
        n = trinormal( vxs );
    end
    numpoints = size(p,1);
    if dot(n,n)==0
        pp = projectPointToLine( vxs([1 2],:), p );
        bc = [ ones(numpoints,1), zeros(numpoints,2) ];
    else
        p1 = p - ones(numpoints,1)*vxs(1,:);
        v21 = vxs(2,:) - vxs(1,:);
        v31 = vxs(3,:) - vxs(1,:);
        v31dotv21 = dot(v21,v31);
        M = [ [ dot(v21,v21), v31dotv21 ]; [ v31dotv21, dot(v31,v31) ] ];
        ab = [ p1*v21', p1*v31' ] / M;
        bc = [ 1-ab(:,1)-ab(:,2), ab(:,1), ab(:,2) ];
        pp = bc*vxs; % vxs(1,:) + ab(1)*v21 + ab(2)*v31;
    end
end
