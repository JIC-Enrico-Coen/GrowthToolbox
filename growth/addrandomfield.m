function m = addrandomfield( m, amount, whichMgen, smoothness, add, whichVertexes )
%mesh = addrandomfield( mesh, amount, whichMgen, smoothness, add )
%   Add or set a random amount of growth factor at every point.  The values added
%   will range from 0 to amount (whether amount is positive or negative).
%   At least one vertex will get 0 and at least one will get amount.
%   If whichMgen specifies more than one morphogen, the random values will
%   be independent for different morphogens, and will range from 0 to
%   amount for each.

    if amount==0, return; end
    if nargin < 5, add = 1; end
    if nargin < 6
        whichVertexes = true(getNumberOfVertexes(m),1);
    end
    if isempty( whichVertexes), return; end
    
    extraGrowth = rand(size(m.morphogens,1),length(whichMgen)) - 0.5;
    if isVolumetricMesh( m )
        extraGrowth = smoothMorphogen( m.FEconnectivity.edgeends, extraGrowth, smoothness );
    else
        extraGrowth = smoothMorphogen( m.edgeends, extraGrowth, smoothness );
    end
    extraGrowth = extraGrowth - repmat(min(extraGrowth,[],1), 1, size(extraGrowth,2));
    maxgrowth = max( extraGrowth, [], 1 );
    if maxgrowth > 0
        extraGrowth = extraGrowth * repmat(amount./maxgrowth, 1, size(extraGrowth,2));
    end
    extraGrowth = extraGrowth(whichVertexes,:);
    if add
        m.morphogens(whichVertexes,whichMgen) = extraGrowth + m.morphogens(whichVertexes,whichMgen);
    else
        m.morphogens(whichVertexes,whichMgen) = extraGrowth;
    end
    m.saved = 0;
end

function g = smoothMorphogen( edges, g, n )
    k = 1;  % The larger this is, the less the value at a vertex is
            % influenced by its neighbours.
            % For stability, k should be at least 1.
    for r=1:n
        gr = k*g; % zeros( size(g) );
        nbs = k*ones( size(g) );
        for i=1:size(edges,1)
            ends = edges(i,:);
            gr(ends,:) = gr(ends,:) + g(ends([2,1]),:);
            nbs(ends) = nbs(ends) + 1;
        end
        g = gr./repmat(nbs,1,size(gr,2)); % g*(k/(k+1)) + gr ./ ((k+1)*nbs);
    end
end
