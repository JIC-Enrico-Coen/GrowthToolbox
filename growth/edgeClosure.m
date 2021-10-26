function edges = edgeClosure( edges, faceedges, edgefaces )
%edges = edgeClosure( edges, faceedges )
%   FACEEDGES is an N*3 list of the indexes of edges belonging to a set of
%   triangles.  EDGEFACES is its inverse.  This will be calculated if not
%   supplied.  EDGES is either a list of edge indexes or a boolean map of
%   the edges.
%
%   The result is the closure of EDGEs under the operation: if two edges of
%   any face are in EDGES, the third edge must also be.  The result will be
%   either a list of edge indexes or a boolean map, according as the input
%   value of EDGES was.

    if nargin < 3
        edgefaces = invertIndexArray( faceedges, [], 'array' );
    end
    ismap = islogical(edges);
    if ismap
        edgemap = edges;
    else
        totalnumedges = max(faceedges(:));
        edgemap = false(1,totalnumedges);
        edgemap(edges) = true;
    end
    faceedgemap = edgemap( faceedges );
    numedgesperface = sum( faceedgemap, 2 );
    twoedgedfaces = numedgesperface==2;
    initNumEdges = sum(edgemap);

    numiters = 0;
    while true
        twoedgedfaceedges = faceedges( twoedgedfaces, : );
        newedgefacemap = ~edgemap( twoedgedfaceedges );
        newedges = unique( twoedgedfaceedges(newedgefacemap) );
        if isempty(newedges)
            if ismap
                edges = edgemap;
            else
                edges = find(edgemap);
            end
            fprintf( 1, '%s: %d iterations, edges init %d, final %d\n', ...
                mfilename(), numiters, initNumEdges, length(edges) );
            return;
        end
        numiters = numiters+1;
        edgemap(newedges) = true;
%         fprintf( 1, '%s: iteration %d, edges ', mfilename(), numiters );
%         fprintf( 1, ' %d', find(edgemap) );
%         fprintf( 1, '\n' );
        
        changedEdgeFaces = edgefaces(newedges,:);
        changedEdgeFaces = changedEdgeFaces(changedEdgeFaces~=0);
        for i=changedEdgeFaces(changedEdgeFaces~=0)'
             numedgesperface(i) = numedgesperface(i)+1;
        end

        updatefaces = unique(changedEdgeFaces);
%         numedgesperface(updatefaces) = sum( faceedgemap(updatefaces,:), 2 );
        % numedgesperface(updatefaces) = numedgesperface(updatefaces)+1;
        twoedgedfaces(updatefaces) = numedgesperface(updatefaces)==2;
    end
end
