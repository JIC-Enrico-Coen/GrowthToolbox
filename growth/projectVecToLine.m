function w = projectVecToLine( v, n )
%w = projectVecToLine( v, n )
%   Find w such that v-w is parallel to n and w is perpendicular to n.
%   n need not be a unit vector.
%   v and n must be row vectors; w will be a row vector.

    if size(n,1)==1
        w = v - n*(v*n')/(n*n');
    else
        w = v - n.*repmat( sum(v.*n,2)./sum(n.*n,2), 1, size(n,2) );
    end
end
    