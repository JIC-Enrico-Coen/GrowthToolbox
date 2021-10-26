function cellcentroids = leaf_cellcentroids( m )
%cellcentroids = leaf_cellcentroids( m )
%   Compute the centroids of all of the biological cells, as an N*3 array.

    numcells = length( m.secondlayer.cells );
    cellcentroids = zeros( numcells, 3 );
    for i=1:numcells
        cellcentroids(i,:) = polyCentroid( m.secondlayer.cell3dcoords( m.secondlayer.cells(i).vxs, : ) );
    end
end
