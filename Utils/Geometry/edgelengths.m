function el = edgelengths( vxs, edgevxs )
%el = edgelengths( vxs, edgevxs )
%   VXS is an N*D array of N vertexes in D-dimensional space.
%   EDGEVXS is a K*2 array listing the pairs of vertexes joined by each of
%   K edges.
%   The result EL is a K*1 array of the length of every edge.

    edgevecs = vxs( edgevxs(:,2), : ) - vxs( edgevxs(:,1), : );
    el = sqrt( sum( edgevecs.^2, 2 ) );
end
