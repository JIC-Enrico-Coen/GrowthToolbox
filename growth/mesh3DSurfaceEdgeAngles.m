function allEdgeAngles = mesh3DSurfaceEdgeAngles( m )
%allEdgeAngles = mesh3DSurfaceEdgeAngles( m )
%   For a volumetric mesh, find the angle across each edge that lies on the
%   surface of the mesh. The result is an N*1 array indexed by edge, for
%   all edges. Edges not on the surface are assigned a value of -1. Edges on
%   the surface will have a value between 0 and pi.

    allEdgeAngles = zeros( getNumberOfEdges(m), 1 ) - 1;

    if isVolumetricMesh( m )
        % Find the surface faces. These are the ones that belong to exactly one
        % finite element.
        surfaceFaces = m.FEconnectivity.facefes(:,2)==0;

        % Find the surface edges. These are all the edges of the surface faces.
        surfaceFaceEdges = [ m.FEconnectivity.faceedges(surfaceFaces,:), find( surfaceFaces ) ];
        % surfaceFaceEdges has four columns. the first three contain the edges
        % of the face whose index appears in the fourth column.
        foo1 = surfaceFaceEdges( :, [1 4 2 4 3 4] );
        foo2 = reshape( foo1', 2, [] )';
        surfaceEdgeFaces = sortrows( foo2 );
        [starts,ends] = runends( surfaceEdgeFaces(:,1) );
        check = ends-starts == 1;
        bad = sum( ~check );
        if bad > 0
            timedFprintf( 'There are %d surface edges belonging to other than two surface faces.\n', bad );
            starts = starts(check);
            ends = ends(check);
        end
        surfaceFaceIndexes = zeros( getNumberOfFaces(m), 1 );
        surfaceFaceIndexes( surfaceFaces ) = (1:sum(surfaceFaces))';
        surfaceEdges = surfaceEdgeFaces( starts, 1 );
        surfaceEdgeFacePairs = [ surfaceEdgeFaces( starts, 2 ), surfaceEdgeFaces( ends, 2 ) ];
        surfaceFaceNormals = trinormals( m.FEnodes, m.FEconnectivity.faces( surfaceFaces, : ) );
        surfaceEdgeAngles = abs( vecangle( surfaceFaceNormals( surfaceFaceIndexes( surfaceEdgeFaces( starts, 2 ) ), : ), ...
                                           surfaceFaceNormals( surfaceFaceIndexes( surfaceEdgeFaces( ends, 2 ) ), : ) ) );
        % This needs to be modified to use the senses of the normals.

%         surfaceEdgesToDraw = surfaceEdgeAngles > pi/3;
%         absoluteEdgesToDraw = surfaceEdges(surfaceEdgesToDraw);
%         foo = m.visible.surfedges(absoluteEdgesToDraw);
%         absoluteEdgesToDraw = absoluteEdgesToDraw(foo);
% 
%         [lw,ls] = basicLineStyle( m.plotdefaults.FEthinlinesize );
%         h = plotlines( m.FEconnectivity.edgeends( absoluteEdgesToDraw, : ), m.FEnodes, ...
%                        'Parent', m.pictures(1), 'LineWidth', lw, 'LineStyle', ls, 'color', m.plotdefaults.FElinecolor );
        allEdgeAngles( surfaceEdges ) = surfaceEdgeAngles;
        xxxx = 1;
    else
    end
    
    xxxx = 1;
end