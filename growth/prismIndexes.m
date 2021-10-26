function p = prismIndexes( n )
%p = prismIndexes( n )
%   Calculate the set of prism node indexes corresponding to the given
%   triangle node vertexes.  If n has class 'logical' it is interpreted as
%   a boolean map of all the nodes and the result is a boolean map of all
%   the prism nodes.  Otherwise n is a list of node indexes and p is a list
%   of prism node indexes.  For each indexe in n, the corresponding two
%   indexes in p will be consecutive, first the A side vertex and then the
%   B side.

    if islogical(n)
        p = reshape( repmat( n(:), 1, 2 )', [], 1 );
    else
        p = n(:)'*2;
        p = reshape( [p-1 ; p], 1, [] );
    end
end
