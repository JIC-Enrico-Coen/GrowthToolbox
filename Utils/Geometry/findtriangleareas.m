function a = findtriangleareas( nodes, tricellvxs )
%m = findtriangleareas( nodes, tricellvxs )
%   Calculate the area of the triangles.

    numcells = size(tricellvxs,1);
    a = trianglearea( permute( reshape( nodes( tricellvxs', : ), 3, [], 3 ), [1,3,2] ) );
end

