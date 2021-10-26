function handles = edgeClick( handles, ei, selectionType )
% This should only be called when the simulation is not running.

    mousemode = getMouseModeFromGUI( handles );
    switch mousemode
        case '----'
            % Should forward.
        case 'mouseeditmodeMenu:Seam edges'
            handles.mesh.seams(ei) = ~handles.mesh.seams(ei);
            % Update plot.
            handles.mesh.selection.highlightedEdges = find( handles.mesh.seams );
            handles.mesh = plotHighlightedEdges( handles.mesh );
            % drawnow;
        case 'mouseeditmodeMenu:Subdivide edge'
            % Not implemented yet.
        case 'mouseeditmodeMenu:Elide edge'
            [handles.mesh,elided] = elideEdge( handles.mesh, ei );
            if elided
                handles = GUIPlotMesh( handles );
            else
                fprintf( 1, 'Could not elide edge %d: quality of mesh is reduced.\n', ei );
            end
        case 'mouseeditmodeMenu:Elide cell pair'
            handles.mesh = elideCells( handles.mesh, ei );
            handles = GUIPlotMesh( handles );
        case 'simulationMouseModeMenu:Show value'
            if ei > 0
                vis = handles.mesh.edgeends(ei,:);
                pts = handles.mesh.nodes(vis,:);
                hitline = get( handles.picture, 'CurrentPoint' );
                hitvec = hitline(2,:)-hitline(1,:);
                midpt = sum(pts,1)/2;
                d1 = dot( midpt-hitvec(1,:), hitvec );
                d2 = dot( pts(1,:)-hitvec(1,:), hitvec );
                isend1 = (d1 > 0)==(d2 > 0);
                vi = vis( isend1 + 1 );
                handles = vertexClick( handles, vi, selectionType );
                
%                 mgenIndex = getDisplayedMgenIndex( handles );
%                 mgenName = handles.mesh.mgenIndexToName{mgenIndex};
%                 text = sprintf( 'Vx %d: %s = %.3g\n', ...
%                     vi, mgenName, handles.mesh.morphogens(vi,mgenIndex) );
%                 set( handles.siminfoText, 'String', text );
            end
        otherwise
            % Should forward vertexclick or cellclick types.
            complain( 'edgeClick: ''%s'' not recognised.\n', mousemode );
    end
end
