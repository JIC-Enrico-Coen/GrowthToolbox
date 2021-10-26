function tris = triarray( polys )
    vxsperpoly = size( polys, 2 );
    if vxsperpoly <= 3
        tris = polys;
    else
        numpolys = size(polys,1);
        numtris = vxsperpoly-2;
        v1 = repmat( polys(:,1), 1, 1, numtris );
        v2 = permute( polys(:,2:(end-1)), [1 3 2] );
        v3 = permute( polys(:,3:end), [1 3 2] );
        tris = reshape( permute( [v1 v2 v3], [2 3 1] ), 3, numtris*numpolys )';
    end
end
