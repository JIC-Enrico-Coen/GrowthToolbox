function vols = tetrahedronVolume( vxs, tetravxs )
%vols = tetrahedronVolume( vxs, tetravxs )
%   Calculate the volumes of the given tetrahedra.
%   VXS is an N*3 array giving the locations of the vertexes.
%   TETRAVXS is a K*4 array listing the indexes of the vertexes of each
%   tetrahedron.
%
%   Volumes are signed: if the vertexes are listed according to the
%   right-hand rule then the volume is positive.

    foo = reshape( vxs( tetravxs', : ), 4, [], 3 );
    foo = foo([2 3 4],:,:) - repmat( foo(1,:,:), 3, 1, 1 );
    foo = permute( foo, [1 3 2] );
    
    vols = squeeze( foo(1,1,:).*(foo(2,2,:).*foo(3,3,:) - foo(2,3,:).*foo(3,2,:)) ...
            + foo(1,2,:).*(foo(2,3,:).*foo(3,1,:) - foo(2,1,:).*foo(3,3,:)) ...
            + foo(1,3,:).*(foo(2,1,:).*foo(3,2,:) - foo(2,2,:).*foo(3,1,:)) )/6;
end
