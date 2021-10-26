function handles = updateSelection( handles, cis, eis, vis, selecting )
%handles = updateSelection( handles, cis, eis, vis, selecting )
%   Update the selection with the given cell, vertex, and edge indices.
%   If SELECTING is 'replace', replace the selection by the given objects.
%   If SELECTING is 'add', add all the given objects to the selection.
%   If SELECTING is 'rem', remove all the given objects from the selection.
%   If SELECTING is 'tog', toggle the state of all the given objects.

%fprintf( 1, 'updateSelection mode %d\n', selecting );
%vis
%highlightedVxs = m.selection.highlightedVxs

    [handles.mesh.selection.highlightedCellList,cellson,cellsoff] = ...
        updateBoolList( handles.mesh.selection.highlightedCellList, cis, selecting );
    [handles.mesh.selection.highlightedEdgeList,edgeson,edgesoff] = ...
        updateBoolList( handles.mesh.selection.highlightedEdgeList, eis, selecting );
    [handles.mesh.selection.highlightedVxList,vxson,vxsoff] = ...
        updateBoolList( handles.mesh.selection.highlightedVxList, vis, selecting );
    
    % Get the current mouse mode
    mousemode = getMouseModeFromGUI( handles );
    switch mousemode
        case '---'
        case 'mouseeditmodeMenu:Fix nodes'
            % Set the selected nodes to have the checked fixed dfs. Ignore
            % the unselected nodes.
            % Or maybe a button to select the fixed nodes and another to
            % fix the selected nodes, eliminating this menu item.
        case 'mouseeditmodeMenu:Locate node'
            % The selection should be either empty or have a single vertex.
            % Perform the location accordingly.
            % Or similar considerations as Fix nodes.
        case 'mouseeditmodeMenu:Delete element'
            % This one is tricky.  Deleting elements while the
            % selection is taking place requires careful attention to how
            % we do the renumbering.  Can we implement undo for this?  If
            % not, better to have a delete button to delete the selection.
        case 'mouseeditmodeMenu:Seam edges'
            % Update the seamed edges
        case 'mouseeditmodeMenu:Subdivide vertex'
        case 'mouseeditmodeMenu:Subdivide edge'
        case 'mouseeditmodeMenu:Subdivide element'
            % The subdivision should happen by a "Refine selected" button.
        case 'mouseeditmodeMenu:Elide edge'
            % There's not much use for this.  Try removing it.
        case 'mouseeditmodeMenu:Elide cell pair'
            % There's not much use for this.  Try removing it.
        case 'morpheditmodeMenu:Add'
            % We can get rid of this.  Use the Add button. If we implement
            % this, we need a way to avoid adding multiple times to a
            % vertex in a single stroke.  Simplest would be to cache the
            % initial values of the current morphogen, and set the values
            % from the selection.  We would want to update the colours by
            % putting them directly into the graphics handle.  That will
            % need some modification of leaf_plot.  The colourbar would
            % also need updating.  We need to be able to do partial
            % replots.  How do we currently handle adding to single
            % vertexes?
        case 'morpheditmodeMenu:Set'
            % We can get rid of this.  Use the Zero and Add buttons.
        case 'morpheditmodeMenu:Fix'
            % Similar to fixing position, using the morphogenclamp values.

        case 'mouseCellModeMenu:Add cell'
        case 'mouseCellModeMenu:Delete cell'
    end
    
    % On selecting the Fix nodes or Locate node item, the selection should
    % be set to the relevant nodes.  Brush and Box modes should be disabled
    % during Locate node.
end
