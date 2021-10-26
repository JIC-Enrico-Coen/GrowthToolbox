function edges = maxdisjointedges( edgeends )
%edges = maxdisjointedges( edgeends )
%   EDGEENDS is an N*2 matrix listing the vertex indexes of the ends of a
%   set of N edges.  This procedure selects a maximal subset of the edges
%   such that no two edges share a vertex.  The result EDGES is a list of
%   indexes of the selected edges.

    unused = true(max(edgeends(:)),1);
    numedges = size(edgeends,1);
    edges = false(numedges);
    for ei=1:numedges
        if all(unused(edgeends(ei,:)))
            edges(ei) = true;
            unused(edgeends(ei,:)) = false;
        end
    end
    edges = find(edges);
end
