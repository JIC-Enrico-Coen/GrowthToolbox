function [badElementMap,badEdgeMap] = checkManifoldSurface( m )
%[badElementMap,badEdgeMap] = checkManifoldSurface( m )
%
%   Force the surface of m to be a manifold, by deleting elements as
%   necessary.

    % Get the surface, without forcing orientation.
    [s,embedding] = extractSurface( m, false );
    
    % Count how many faces each edge belongs to.
    zz = accumarray( s.celledges(:), 1 );
    
    % More than two is bad.
    badEdges = embedding.edgeSurfaceToVolIndex( zz>2 );
    badEdgeMap = false( getNumberOfEdges(m), 1 );
    badEdgeMap( badEdges ) = true;
    
    % Elements containing these edges are bad.
    badElementMap = any( badEdgeMap( m.FEconnectivity.feedges ), 2 );
    
    
    % For each surface vertex, find all the elements and faces containing
    % that vertex.
    
    % For those elements and faces, define a relation on elements of
    % "sharing a face".
    
    % Find the cliques of that relation.
    
    % If there is more than one clique, split the vertex into one copy for
    % each clique.
    
    % This may involve splitting edges too: every edge belonging to more
    % than one clique must be split at that vertex.
    

    % 1. Find all surface faces.

    % 2. For each edge of those faces, find how many of those faces
    % they belong to. Problematic edges are those belonging to more
    % than two faces.

    % 3. Add all elements that include any of these edges to the
    % deletion list.

    % 4. Find all surface vertexes of the new mesh. These are all
    % vertexes belonging to new surface edges.

    % 5. For each such vertex, find the surface faces and edges
    % they belong to.

    % 6. Determine how many cycles those edges and faces split
    % into. Problematic vertexes are those with more than one
    % cycle.

    % 7. Add all elements that include any of these vertexes to the
    % deletion list.
    
    
    
    % m = leaf_deleteElements( m, badElementMap );
end
