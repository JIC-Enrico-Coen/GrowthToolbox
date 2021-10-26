function simpleplotmesh( nodes, triangles )
reshape( nodes( triangles', 1 ), 3, [] )
reshape( nodes( triangles', 2 ), 3, [] )
reshape( nodes( triangles', 3 ), 3, [] )
    fill3( reshape( nodes( triangles', 1 ), 3, [] ), ...
           reshape( nodes( triangles', 2 ), 3, [] ), ...
           reshape( nodes( triangles', 3 ), 3, [] ), 'b' );
end
