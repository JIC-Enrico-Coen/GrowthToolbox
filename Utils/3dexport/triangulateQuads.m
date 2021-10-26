function tris = triangulateQuads( quads )
    tris = reshape( quads(:,[ 1 2 3 1 3 4 ])', 3, [] )';
end
