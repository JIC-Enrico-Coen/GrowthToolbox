function mesh = setemptymesh( numpoints, numedges, numcells )
    mesh.nodes = zeros( numpoints, 3 );
    mesh.tricellvxs = zeros( numcells, 3, 'int32' );
    
    mesh.edgeends = zeros( numedges, 2, 'int32' );
    mesh.edgecells = zeros( numedges, 2, 'int32' );
    mesh.celledges = zeros( numcells, 3, 'int32' );
end
