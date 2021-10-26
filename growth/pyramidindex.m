function n = pyramidindex( i, j, k )
%n = pyramidindex( i, j, k )
%n = pyramidindex( ijk )
%   Given the non-negative integer coordinates of a vertex in the infinite
%   regular tetrahedron, calculate the index of the vertex.
%
%   In the first form, I, J, and K can be matrices all of the same shape,
%   and N will have the same shape.
%
%   In the second form, IJK is a 3-column matrix and N will be a column
%   vector.
%
%   In all cases, we have pyramidindex( pyramidsplitindex( n ) ) == n and
%   pyramidsplitindex( pyramidindex( ijk ) ) == ijk 
%
%   See also: pyramidsplitindex.

    if nargin==1
        k = i(:,3);
        j = i(:,2);
        i = i(:,1);
    end
    row = j+k;
    layer = i+row;
    n = reshape( (layer.*(layer+1).*(layer+2))/6 + (row.*(row+1))/2 + k, size(i) );
end
