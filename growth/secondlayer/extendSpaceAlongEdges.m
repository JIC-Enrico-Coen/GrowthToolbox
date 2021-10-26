function m = extendSpaceAlongEdges( m, vi )
%m = extendSpaceAlongEdges( m, vi )
%   vi is a vertex of the bio layer which borders an air space.
%   Rip all of the edges ending at v which are not borders of the air
%   space, by a certain distance d, or the length of the edge, whichever is
%   shorter.
%
%   INCOMPLETE, PERHAPS A DEAD END.

    % Find all cells and edges that v belongs to.
    edgesOnVMap = any( m.secondlayer.edges(:,[1 2])==vi, 2 );
    edgeDataV = m.secondlayer.edges(edgesOnVMap,:)
    cellsOnV = unique( sort( reshape( edgeDataV(:,[3,4]), [], 1 ) ) );
    if cellsOnV(1) ~= -1
        return;
    end
    edgesOnV = unique( sort( reshape( edgeDataV(:,[1,2]), [], 1 ) ) );
    edgesOnV(edgesOnV==vi) = []
end
