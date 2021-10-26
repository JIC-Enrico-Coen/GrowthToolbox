function ta = trianglearea( vxs )
%ta = trianglearea( vxs )
%   Compute the area of the triangle in 3D space whose vertices are the
%   rows of vxs.  If the third dimension of vxs is greater than 1, this
%   calculation will be carried out for every slice.

    side1 = vxs(2,:,:) - vxs(1,:,:);
    side2 = vxs(3,:,:) - vxs(1,:,:);
    crossprods = crossproc2( side1, side2 );
    ta = sqrt(sum( crossprods.^2, 2 ))/2;
    ta = ta(:);
end

