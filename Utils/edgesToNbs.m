function nbs = edgesToNbs( edges, numitems )
%nbs = edgesToNbs( edges, numitems )
%   20220302 DOES NOT WORK YET. Need to take transitive closure.

    if nargin < 2
        numitems = max(edges(:));
    end
    
    edges = [edges; edges(:,[2 1])];
    edges = sortrows( edges );
    [starts,ends,uv] = runends( edges(:,1) );
    nbs = cell( numitems, 1 );
    for i=1:numitems
        nbs{i} = zeros(1,0);
    end
    for i=1:length(starts)
        nbs{uv(i)} = edges(starts(i):ends(i),2)';
    end
    nbs = cellToRaggedArray( nbs, 0 );
end