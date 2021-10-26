function edges = edgeClosureLower( m, edges )
%edges = edgeClosure( m, edges )
%   EDGES is either a list of edge indexes or a boolean map of
%   the edges.
%
%   The result is a subset of EDGES such that no triangle contains exactly
%   two selected edges.

    ismap = islogical(edges);
    if ismap
        edgemap = edges;
    else
        totalnumedges = max(m.FEconnectivity.faceedges(:));
        edgemap = false(1,totalnumedges);
        edgemap(edges) = true;
    end
    
    % For every triangle of which two edges are selected, look at the
    % number of edges selected in its corresponding neighbours.  Let these
    % numbers be A and B, and using 0 for the case where there is no
    % neighbour.
    %
    % If A==2, drop the corresponding edge.
    % If B==2, drop the corresponding edge.
    % If A==3, drop edge B.  If B==3 also, add that triangle to a list of
    %   new potentially bad triangles.
    % Otherwise, drop A.
    
    

    numiters = 0;
    edgelengthsq = zeros( size(m.FEconnectivity.edgeends,1), 1 );
    while true
        numiters = numiters+1;
        faceedgemap = edgemap( m.FEconnectivity.faceedges );
        numedgesperface = sum( faceedgemap, 2 );
        twoedgedfaces = numedgesperface==2;
        fprintf( 1, 'Iteration %d.  Edges to split: %d, two-edged faces: %d\n', numiters, sum(edgemap), sum(twoedgedfaces) );
        if ~any(twoedgedfaces)
            fprintf( 1, 'Iteration finished at step %d.\n', numiters );
            break;
        end
        
        twoedgedfaceedges = m.FEconnectivity.faceedges(twoedgedfaces,:);
        twoedgedfaceedgeselected = edgemap( twoedgedfaceedges );
        xx = twoedgedfaceedges';
        faceselectededges = reshape( xx( twoedgedfaceedgeselected' ), 2, size(twoedgedfaceedges,1) )';
        
        edgeends = m.FEconnectivity.edgeends(edgemap,:);
        edgelengthsq(edgemap) = sum( (m.FEnodes( edgeends(:,1), : ) - m.FEnodes( edgeends(:,2), : )).^2, 2 );
        faceedgelengthsq = reshape( edgelengthsq( faceselectededges ), [], 2 );
        discardfirst = faceedgelengthsq(:,1) < faceedgelengthsq(:,2);
        unique( [ faceselectededges(discardfirst,1); faceselectededges(~discardfirst,2) ] );

        edgesToDiscard = unique( [ faceselectededges(discardfirst,1); faceselectededges(~discardfirst,2) ] );
        edgemap(edgesToDiscard) = false;
    end
    
    edges = find(edgemap);
    
    
    
end
