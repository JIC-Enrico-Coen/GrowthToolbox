function [ edgeVxs, edgeEdges, edgeCells ] = edgeData( m, vi )
%[ edgeVxs, edgeEdges, edgeCells ] = edgeData( m, vi )
%   If vi is a vertex on the edge of the leaf, find the two edges incident
%   on that vertex, and the vertexes at the other ends of those edges, and
%   the cells that the edges belong to.

    % Find all edges incident on vi.
    incidentEdges = 1 + ...
        mod( unique( find( m.edgeends==vi ) ) - 1, size(m.edgeends,1) );

    % Find those having a cell on only one side.
    edgeEdges = incidentEdges(m.edgecells( incidentEdges, 2 )==0);
    
    % Find the other ends of those edges
    edgeVxs = zeros(size(edgeEdges));
    for i=1:length(edgeEdges)
        ei = edgeEdges(i);
        if m.edgeends(ei,1)==vi
            edgeVxs(i) = m.edgeends(ei,2);
        else
            edgeVxs(i) = m.edgeends(ei,1);
        end
    end
  % edgeVxs
    edgeCells = m.edgecells(edgeEdges,1);
end
