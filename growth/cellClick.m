function handles = cellClick( handles, ci, bc, pt, selectionType )
%handles = cellClick( handles, ci, bc, pt, selectionType )
%   Handle a click on element ci at barycentric coordinates bc and global
%   coordinates pt.
%   This should only be called when the simulation is not running.

    if (ci ~= 0) && ~isempty(handles.mesh)
        output = handles.output;
        mousemode = getMouseModeFromGUI( handles );
%   fprintf( 1, 'cellclick ci %d bc [%.2f %.2f %.2f] pt [%.2f %.2f %.2f] sel ''%s''\n', ...
%       ci, bc, pt, mousemode );
        switch mousemode
            case 'mouseeditmodeMenu:Delete element'
                attemptCommand( handles, false, true, ... % WARNING: Does not always need redraw.
                    'deletepatch', ci );
                handles = guidata( output );
                handles = GUIPlotMesh( handles );
            case 'bioBedit'
                attemptCommand( handles, false, false, ...
                    'addbioregion', ci );
                handles = guidata( output );
                handles = GUIPlotMesh( handles );
            case 'mouseeditmodeMenu:Subdivide element'
                fprintf( 1, '** Manual subdivision not implemented yet.\n' );
                % Subdivide the cell into four, and split each of the
                % neighbouring cells.
            case { 'mouseeditmodeMenu:Add', 'mouseeditmodeMenu:Set', 'mouseeditmodeMenu:Fix', ...
                   'mouseeditmodeMenu:Fix nodes', 'mouseeditmodeMenu:Locate node', 'mouseeditmodeMenu:Subdivide node' }
                % Really a vertex click.
                % Find the hit point and take the closest vertex.
                [mbc,cvi] = max(bc);
                vi = handles.mesh.tricellvxs(ci,cvi);
                handles = vertexClick( handles, vi, selectionType );
            case { 'simulationMouseModeMenu:Show value' }
                if ~isempty( handles.mesh.plotdata )
                    if handles.mesh.plotdata.pervertex
                        % Really a vertex click.
                        % Find the hit point and take the closest vertex.
                        [mbc,cvi] = max(bc);
                        vi = handles.mesh.tricellvxs(ci,cvi);
                        handles = vertexClick( handles, vi, selectionType );
                    else
                        % Come here if the plot mode is per-cell and display
                        % the value for the hit cell.
                        text = sprintf( 'FE %d: %s = %.3g\n', ...
                            ci, handles.mesh.plotdata.description, handles.mesh.plotdata.value(ci) );
                        set( handles.siminfoText, 'String', text );
                    end
                end
            case { 'mouseeditmodeMenu:Seam edges', 'mouseeditmodeMenu:Subdivide edge', 'mouseeditmodeMenu:Elide edge', 'mouseeditmodeMenu:Elide cell pair' }
                % Really an edge click.
                % Find the hit point and take the closest edge = the most
                % distant vertex.
                [mbc,cei] = min(bc);
                ei = handles.mesh.celledges(ci,cei);
                handles = edgeClick( handles, ei, selectionType );
            otherwise
                fprintf( 1, 'cellClick: unknown action %s.\n', mousemode );
        end
    end
end
