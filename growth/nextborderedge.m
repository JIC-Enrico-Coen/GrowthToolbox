function [e,v] = nextborderedge( m, ei, vi )
%[e,v] = nextborderedge( m, ei, vi )
%   If ei is the index of a border edge of m, and vi is the index of the
%   vertex at one end of ei, find the index of the other border edge
%   impinging on vi, and the vertex at its other end.

    borderedges = find( m.edgecells(:,2)==0 );
    viedges = borderedges(any(m.edgeends(borderedges,:)==vi,2));
    if length(viedges==2)
        e = viedges(viedges ~= ei);
        ends = m.edgeends(e,:);
        v = ends(ends ~= vi);
    else
        e = 0;
        v = 0;
    end
end
