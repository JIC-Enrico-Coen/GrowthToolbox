function k = cellshapes( m )
%k = cellshapes( m )
% Calculate a measure of the shape of each biological cell of m.
%   The result is an N*3 array giving three values in descending order for
%   each cell. These are relative measures of the length of the cell's
%   major axis, the length of its minor axis, and its thickness (which
%   should be close to zero and the smallest of the three).
%
%   NEVER USED -- use leaf_cellshapes instead.
    
    numcells = length(m.secondlayer.cells);
    k = zeros(numcells,3);
    for i=1:numcells
        pts = m.secondlayer.cell3dcoords( m.secondlayer.cells(i).vxs, : );
        [~,k(i,:)] = fitEllipsoid( pts );
    end
    k = 2 * sqrt(abs(k));
end
