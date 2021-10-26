function updateBoxSelection( clickData )
%     fprintf( 1, 'updateBoxSelection\n' );
    if isempty( clickData.polygonC )
        return;
    end
    
    inside = pointInPoly( clickData.meshvxsC, clickData.polygonC );
    
    % If the mouse mode is 'extend', we add all new points to the
    % selection.  If it is 'alt', we remove them.  If it is 'normal', we
    % replace the old selection by the new.
    
    % Those that are already highlighted should remain highlighted, so we
    % need only test visibility of unhighlighted points.
    
    % Find which of these vertexes are visible.
    vispts = visiblePoint( clickData.meshvxsC, clickData.meshfaces, find(inside) );
    
    gd = guidata( clickData.axes );
    currentHighlightedVxMap = listToBitmap( gd.mesh.selection.highlightedVxList, size( clickData.meshvxsC, 1 ) );
    currentVisPts = gd.mesh.visible.nodes;
    
    % Retain only the visible inside points.  This is the new selected set.
    inside(inside) = vispts;
%     fprintf( 1, 'uBS: Current' );
%     fprintf( 1, ' %d', find( currentHighlightedVxMap ) );
%     fprintf( 1, '\n' );
%     fprintf( 1, 'uBS: Enclosed' );
%     fprintf( 1, ' %d', find( inside ) );
%     fprintf( 1, '\n' );
    
    newhighlightVxMap = currentHighlightedVxMap;
    mouseSelType = clickData.mouseSelType;
    switch clickData.mouseSelType
        case 'extend'
            newhighlightVxMap(currentVisPts) = currentHighlightedVxMap(currentVisPts) | inside;
        case 'alt'
            newhighlightVxMap(currentVisPts) = currentHighlightedVxMap(currentVisPts) & ~inside;
%             fprintf( 1, 'Removing' );
%             fprintf( 1, ' %d', find( ~newhighlightVxMap & currentHighlightedVxMap ) );
%             fprintf( 1, '\n' );
        otherwise
            newhighlightVxMap(currentVisPts) = inside;
    end
    
    if any( currentHighlightedVxMap ~= newhighlightVxMap )
        gd.mesh.selection.highlightedVxList = find(newhighlightVxMap);
        gd.mesh = plotHighlightedVertexes( gd.mesh, clickData.axes );
        guidata( clickData.axes, gd );
    end
%     fprintf( 1, 'uBS: After updating' );
%     fprintf( 1, ' %d', gd.mesh.selection.highlightedVxList );
%     fprintf( 1, '\n' );
end

