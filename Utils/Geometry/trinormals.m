function normals = trinormals( vxs, tris )
%normals = trinormals( vxs, tris )
%   Calculate a unit normal vector for each of the triangles.

    trivecs = permute( reshape( vxs(tris',:), 3, [], 3 ), [1 3 2] );  % corner * dim * tri
    v1 = shiftdim( trivecs(2,:,:) - trivecs(1,:,:), 1 );
    v2 = shiftdim( trivecs(3,:,:) - trivecs(1,:,:), 1 );
    normals = cross( v1, v2, 1 )';
    norms = sqrt(sum(normals.^2,2));
    normals = normals ./ repmat( norms, 1, 3 );
end
