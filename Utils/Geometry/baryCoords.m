function [bc,baryCoords_err,n,v_in_plane] = baryCoords( vxs, n, v, within )
%[bc,baryCoords_err,n] = baryCoords( vxs, n, v, within )
%   Calculate the barycentric coordinates of point v with respect to
%   triangle vxs, in three dimensions.  vxs contains the three vertexes of
%   the triangle as rows. n is a normal vector to the triangle.  If n is
%   empty it will be computed.  If supplied, it may be of any non-zero
%   length.
%   The component of v perpendicular to the plane of the
%   triangle is ignored.
%   n and v must be row vectors, and the result is a 3-element row vector.
%   v can also be a matrix of row vectors; the result will then be a matrix
%   of 3-element row vectors.
%   vxs must specify a single triangle.
%   If within is true (default is false) then bc is forced to be all
%   non-negative.  baryCoords_err will be the distance from the new point
%   to the original point.
%   This procedure works in 3 dimensions only.

    if isempty(n)
        n = trinormal( vxs );
    end
    
    if nargin < 4
        within = false;
    end
    
    v1 = vxs(1,:);
    v2 = vxs(2,:);
    v3 = vxs(3,:);
    v_in_plane = zeros(size(v));
    nsq = n*n';
    for i=1:size(v,1)
        v_in_plane(i,:) = v(i,:) + (((v1-v(i,:))*n')/nsq)*n;  % v_in_plane is in the plane of the triangle.
    end
    
    a1 = cross3( v2-v3, n );
    oneval = dot3(a1,v1);
    zeroval = dot3(a1,v2);
    vval = v_in_plane*a1';
    b1 = (vval-zeroval)/(oneval-zeroval);
    
    a2 = cross3( v3-v1, n );
    oneval = dot3(a2,v2);
    zeroval = dot3(a2,v3);
    vval = v_in_plane*a2';
    b2 = (vval-zeroval)/(oneval-zeroval);
    
    a3 = cross3( v1-v2, n );
    oneval = dot3(a3,v3);
    zeroval = dot3(a3,v1);
    vval = v_in_plane*a3';
    b3 = (vval-zeroval)/(oneval-zeroval);
    
    bc = [ b1, b2, b3 ];
    
    if within && any(bc<0)
        negbc = bc<0;
        numneg = sum(negbc);
        if numneg==2
            bc = [ 0 0 0 ];
            bc(find(~negbc,1)) = 1;
        else
            i = find(negbc);
            j = 1+mod(i,3);
            k = 1+mod(j,3);
            [~,bc2] = nearestPointOnLine( vxs([j k],:), v );
            bc2 = max(0,min(1,bc2));
            bc([i j k]) = [0 (1-bc2) bc2];
        end
    end
    
    if nargout > 1
        baryCoords_err = sqrt( sum( (bc*vxs-v_in_plane).^2, 2 ) );
        % baryCoords_err = norm(bc*vxs-vv);
    end
end

function d = dot3( v1, v2 )
%v3 = dot3( v1, v2 )
%   Dot product of two 3-element row vectors.

    d = v1(1)*v2(1) + v1(2)*v2(2) + v1(3)*v2(3);
end

function v3 = cross3( v1, v2 )
%v3 = dot3( v1, v2 )
%   Dot product of two 3-element row vectors.

    v3 = [ v1(2)*v2(3) - v1(3)*v2(2), ...
           v1(3)*v2(1) - v1(1)*v2(3), ...
           v1(1)*v2(2) - v1(2)*v2(1) ];
end
