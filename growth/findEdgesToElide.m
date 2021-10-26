function [eis,q] = findEdgesToElide( m, threshold )
% eis = findEdgesToElide( m )
%   An edge can be elided if the triangles on both sides have a narrow
%   angle opposite to the edge, and if eliding the edge does not have a bad
%   effect on any triangles.

    if nargin < 2
        threshold = 0.2;
    end
    
    numedges = size(m.edgeends,1);
    cellangles = femCellAngles( m );
    
    edgequality = zeros(size(m.edgeends,1),1);
    for ei=1:numedges
        c1 = m.edgecells(ei,1);
        c1ei = find( m.celledges(c1,:)==ei, 1 );
        eq = cellangles(c1,c1ei);
        c2 = m.edgecells(ei,2);
        if c2 ~= 0
            c2ei = find( m.celledges(c2,:)==ei, 1 );
            eq = min( eq, cellangles(c2,c2ei) );
        end
        edgequality(ei) = eq;
    end
    badedges = find(edgequality < threshold);
    edgequality = edgequality(badedges);
    [q,perm] = sort(edgequality);
    eis = badedges(perm);
end
