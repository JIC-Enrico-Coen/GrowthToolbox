function [sharpEdgeMap,sharpVxMap] = findSharpEdges( m, angle )
%sharpEdges = findSharpEdges( m, angle )
%   Determine which edges and vertexes of m are "sharp". The results are
%   returned as boolean maps of the edges and vertexes.
%
%   A sharp edge is one that lies on the surface of the mesh, and for
%   which the normal axes of the surface faces on either side make an
%   angle whose absolute value is greater than the given angle. The result
%   is a boolean map of the edges specifying which of them are sharp. Sharp
%   edges can be either convex or concave.
%
%   Normal axes are undirected, and the angle between them is necessarily
%   in the range 0 to pi/2. If the angle between normal vectors is e.g. 100
%   degrees, the angle between the normal axes is 80 degrees.
%
%   A sharp vertex is a vertex that belongs to at least three sharp
%   edges.
%
%   This procedure applies only to volumetric meshes. For a foliate mesh
%   the result is false everywhere.

    sharpEdgeMap = false( getNumberOfEdges(m), 1 );
    sharpVxMap = false( getNumberOfVertexes(m), 1 );
    
    if ~isVolumetricMesh( m )
        return;
    end
    
    surfaceEdges = m.FEconnectivity.edgeloctype==1;
    surfaceEdgeFaces = m.FEconnectivity.edgefaces( surfaceEdges, : )'; % N x numsurfedges
    surfaceEdgesSurfFaces = surfaceEdgeFaces;
    surfaceEdgesSurfFaces( surfaceEdgesSurfFaces ~= 0 ) = m.FEconnectivity.faceloctype ( surfaceEdgesSurfFaces( surfaceEdgesSurfFaces ~= 0 ) );
    surfaceEdgesSurfFaces = logical(surfaceEdgesSurfFaces);
    goodEdges = sum( surfaceEdgesSurfFaces, 1 ) == 2;
    surfaceEdges( ~goodEdges, : ) = false;
    numsurfedges = sum( goodEdges );
    surfaceEdgesSurfFaces( :, ~goodEdges ) = [];
    surfaceEdgeFaces1 = reshape( surfaceEdgeFaces( surfaceEdgesSurfFaces ), 2, numsurfedges ); % 2 x numsurfedges
    
    
    surfaceFaceVxindexes = m.FEconnectivity.faces( m.FEconnectivity.faceloctype==1, : );
    surfaceNormals = zeros( size( m.FEconnectivity.faces, 1 ), 3 );
    surfaceNormals( m.FEconnectivity.faceloctype==1, : ) = trinormals( m.FEnodes, surfaceFaceVxindexes );
    
    surfaceEdgeFaceNormals = surfaceNormals( surfaceEdgeFaces1, : ); % (2 x numsurfedges) x dims
    
    surfaceEdgeAngles = vecangle( surfaceEdgeFaceNormals(1:2:end,:), surfaceEdgeFaceNormals(2:2:end,:) ); % All in [0,pi).
    surfaceEdgeAngles1 = min( surfaceEdgeAngles, pi-surfaceEdgeAngles );
    
    sharpSurfaceEdges = surfaceEdgeAngles1 > angle;
    surfaceEdgeIndexes = find( surfaceEdges );
    sharpEdgeMap( surfaceEdgeIndexes(sharpSurfaceEdges) ) = true;
    
    vxsOnSharpEdges = sort( reshape( m.FEconnectivity.edgeends( sharpEdgeMap, : ), [], 1 ) );
    [starts,ends] = runends( vxsOnSharpEdges );
    sharpVxs = vxsOnSharpEdges( starts( ends-starts >= 2 ) );
    sharpVxMap( sharpVxs ) = true;
end