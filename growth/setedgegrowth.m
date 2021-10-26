function m = setedgegrowth( ...
                m, ...
                maxgf, ...
                whichGrowth, ...
                add, ...
                whichVertexes )
    if nargin < 4, add = 0; end
    if nargin < 5
        whichVertexes = true(size(m.nodes,1),1);
    end
    if isempty(whichVertexes), return; end
    newgrowth = zeros( size(m.morphogens,1), length(whichGrowth) );
    ends = bordervertexes( m );
    newgrowth(ends) = maxgf;
    newgrowth = newgrowth(whichVertexes,:);
    if add
        m.morphogens(whichVertexes,whichGrowth) = newgrowth + m.morphogens(whichVertexes,whichGrowth);
    else
        m.morphogens(whichVertexes,whichGrowth) = newgrowth;
    end
    m.saved = 0;
end

    
    
    
    
    
    
