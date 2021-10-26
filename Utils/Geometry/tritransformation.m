function mx = tritransformation( vxsA, vxsB )
%mx = tritransformation( vxsA, vxsB )
%   Compute a linear transformation mapping the triangle whose vertexes are
%   the rows of vxsA to the triangle given by vxsB, assuming the unit
%   normal vector of the first is mapped to the unit normal vector of the
%   second.  mx should have the property that vxsA*mx differs from vxsB by
%   a translation.  The translation from vxsA*mx to vxsB is
%   vxsB(1,:) - vxsA(1,:)*mx.

    mxA = triangleframe( vxsA );
    mxB = triangleframe( vxsB );
    mx = inv(mxA)*mxB;
end

function mx = triangleframe( vxs )
    v1 = vxs(2,:) -vxs(1,:);
    v2 = vxs(3,:) -vxs(1,:);
    v3 = cross( v1, v2 );
    v3 = v3/sqrt(sum(v3.*v3));
    mx = [ v1; v2; v3 ];
end
