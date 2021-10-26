function centroids = biocellCentroids( m, cells )
%centroids = biocellCentroids( m, cells )
%   Calculate the centroids of the biological cells specified by CELLS,
%   which can be a list of cell indexes or a boolean map.  If omitted, it
%   computes the centroids of all cells.

    if nargin < 2
        cells = 1:length(m.secondlayer.cells);
    elseif islogical(cells)
        cells = find(cells);
    end
    
    centroids = zeros( length(cells), 3 );
    for i=1:length(cells)
        vxs = m.secondlayer.cell3dcoords( m.secondlayer.cells(cells(i)).vxs, : );
        centroids(i,:) = polyCentroid( vxs );
    end
end

        