function handles = vertexClick( handles, vi, selectionType )
%handles = vertexClick( handles, vi, selectionType )
%   Processes all clicks on vertexes.
%   This should only be called when the simulation is not running.
%
%   See also: edgeClick, cellClick.

    if (vi ~= 0)
        mousemode = getMouseModeFromGUI( handles );
        % fprintf( 1, 'Clicked vertex %d in mode ''%s''.\n', vi, mousemode );
        switch mousemode
            case '----'
            case { 'morpheditmodemenu:Add', 'morpheditmodemenu:Set' }
%                 fprintf( 1, 'vertexClick mode = %s\n', mousemode );
                handles = paintVertex( handles, vi, ...
                    strcmp( 'morpheditmodemenu:Add', mousemode ) );
                handles = GUIPlotMesh( handles );
            case { 'morpheditmodemenu:Fix' }
                handles = fixVertexMgen( handles, vi );
                handles = GUIPlotMesh( handles );
            case 'mouseeditmodeMenu:Fix nodes'
                handles = fixVertexDF( handles, vi, ...
                    get( handles.fixXbox, 'Value' ), ...
                    get( handles.fixYbox, 'Value' ), ...
                    get( handles.fixZbox, 'Value' ) );
                handles = GUIPlotMesh( handles );
            case 'mouseeditmodeMenu:Locate node'
                handles = locateVertexDF( handles, vi, ...
                    get( handles.fixXbox, 'Value' ), ...
                    get( handles.fixYbox, 'Value' ), ...
                    get( handles.fixZbox, 'Value' ) );
                handles = GUIPlotMesh( handles );
            case { 'simulationMouseModeMenu:Show value' }
                handles = updateVertexInfoDisplay( handles, vi, getDisplayedMgenIndex( handles ) );
%                 mgenIndex = getDisplayedMgenIndex( handles );
%                 mgenName = handles.mesh.mgenIndexToName{mgenIndex};
%                 text = sprintf( 'Vx %d: %s = %.3g\n', ...
%                     vi, mgenName, handles.mesh.morphogens(vi,mgenIndex) );
%                 set( handles.siminfoText, 'String', text );
            case 'mouseeditmodeMenu:Subdivide vertex'
                % Not implemented.
            otherwise
                fprintf( 1, 'vertexClick: unknown action %s.\n', mousemode );
        end
    end
end
