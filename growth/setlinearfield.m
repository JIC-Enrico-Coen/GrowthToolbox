function m = setlinearfield( ...
                    m, ...
                    range, ...
                    whichGrowth, ...
                    direction, ...
                    add, ...
                    whichVertexes )
%m = setlinearfield( m, range, whichGrowth, direction, add )    Set a field of
%growth factor with a linear gradient in a given direction.

    if (nargin < 4) || isempty(direction)
        direction = [1,0,0];
    end
    if (nargin < 5) || isempty(add)
        add = 0;
    end
    if (nargin < 6) || isempty(whichVertexes)
        whichVertexes = true(size(m.morphogens,1),1);
    end
    if isempty(whichVertexes), return; end
    
    if length(direction)==1
        % direction is an angle with the X axis in radians.
        direction = [ cos(direction), sin(direction), 0 ];
    end

    full3d = usesNewFEs( m );
    if full3d
        nodes = m.FEnodes(whichVertexes,:);
    else
        m = makeTRIvalid( m );
        nodes = m.nodes(whichVertexes,:);
    end
    numnodes = size(nodes,1);

    newgrowth = zeros( numnodes, 1 );
    for i=1:numnodes
        lincoord = dotproc2( direction, nodes(i,1:3) );
        newgrowth(i) = lincoord;
    end
    ming = min( newgrowth );
    maxg = max( newgrowth );
    if maxg==ming
        newgrowth = range(1);
    else
        newgrowth = (newgrowth - ming)*((range(2)-range(1))/(maxg-ming)) + range(1);
    end
    newgrowth = repmat( newgrowth, 1, length(whichGrowth) );
    if add
        m.morphogens(whichVertexes,whichGrowth) = newgrowth + m.morphogens(whichVertexes,whichGrowth);
    else
        m.morphogens(whichVertexes,whichGrowth) = newgrowth;
    end
    m.saved = 0;
end
