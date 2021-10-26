function m = setradialfield(m,incr,whichGrowth,centre,power,add,whichVertexes)
%MESH = SETRADIALFIELD(MESH,INCR,CENTRE)  Set growthfactor for all points.
    if nargin < 4, centre = [0, 0, 0]; end
    if nargin < 5, power = 1; end
    if nargin < 6, add = 0; end
    if nargin < 7
        whichVertexes = true(size(m.nodes,1),1);
    end
    if isempty(whichVertexes), return; end
    
    full3d = usesNewFEs( m );
    if full3d
        nodes = m.FEnodes(whichVertexes,:);
    else
        nodes = m.nodes(whichVertexes,:);
    end
    numnodes = size(nodes,1);
    
    m = makeTRIvalid( m );
    newgrowth = zeros( numnodes, 1 );

    for i=1:numnodes
        v = nodes(i,1:3) - centre;
        newgrowth(i) = ((v*v')^power)*incr;
    end
    ming = min( newgrowth );
    if ming < 0
        newgrowth = newgrowth - ming;
    end
    maxg = max( newgrowth );
    if maxg > 0
        newgrowth = newgrowth * abs(incr)/maxg;
    end
    newgrowth = repmat( newgrowth, 1, length(whichGrowth) );
    if add
        m.morphogens(whichVertexes,whichGrowth) = newgrowth + m.morphogens(whichVertexes,whichGrowth);
    else
        m.morphogens(whichVertexes,whichGrowth) = newgrowth;
    end
    m.saved = 0;
end


    
