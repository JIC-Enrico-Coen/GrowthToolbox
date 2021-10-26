function [nbs,numnbs] = getNeighbourVertexes( ee, vxs )
%nbs = getNeighbourVertexes( ee, vxs )
%   ee is an N*2 array of N pairs of vertex indexes.
%   vxs is a K*1 array of vertex indexes.
%   For each vertex, find all the neighbours of that vertex.
%
%   The result is an array of lists of vertex indexes, wose i'th row lists
%   the neighbours of vertex vxs(i).
%
%   As different vertexes may have different numbers of neighbours, the
%   rows are padded at the end with zeros as necessary to make a
%   rectangular array.  numnbs is an K*1 array giving the numbers of
%   neighbours.

    nbs = zeros( length(vxs), 10 );
    numnbs = zeros( length(vxs), 1 );
    for i=1:size(ee,1)
        v1 = ee(i,1);
        v2 = ee(i,2);
        numnbs(v1) = numnbs(v1)+1;
        numnbs(v2) = numnbs(v2)+1;
        nbs( ee(i,1), numnbs(v1) ) = ee(i,2);
        nbs( ee(i,2), numnbs(v2) ) = ee(i,1);
    end
    nbs( :, (max(numnbs)+1):end ) = [];
end
