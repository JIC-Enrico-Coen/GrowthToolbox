function g = meshgrad( m, f )
%g = meshgrad( m, f )
%   m is a mesh of which at least m.nodes and m.tricellvxs exist, and f is
%   a column vector containing one value for each node.
%   Calculate a N*D matrix g, where N is the number of nodes and D the
%   number of dimensions, in which row i is the gradient vector of f
%   over cell i.

    numcells = size(m.tricellvxs,1);
    numdims = size(m.nodes,2);
    g = zeros(numcells,numdims);
    for i=1:numcells
        g(i,:) = grad( m.nodes( m.tricellvxs(i,:), : ), f(m.tricellvxs(i,:))' );
    end
end
