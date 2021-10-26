function cc = biocellcentres( m, ci )
%function cc = biocellcentres( m, ci )
%   Calculate the centroid of every biological cell, or a specified set of cells.

    if isempty(m.secondlayer)
        cc = zeros(0,3);
        return;
    end
    
    if nargin < 2
        ci = 1:length(m.secondlayer.cells);
    end
    numcells = length(ci);
    cc = zeros( numcells, 3 );
    for i=1:numcells
%         cc(i,:) = sum( m.secondlayer.cell3dcoords( m.secondlayer.cells(ci(i)).vxs, : ), 1 )/length( m.secondlayer.cells(ci(i)).vxs );
        cc(i,:) = polyCentroid( m.secondlayer.cell3dcoords( m.secondlayer.cells(ci(i)).vxs, : ) );
    end
end
