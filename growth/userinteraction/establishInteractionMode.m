function handles = establishInteractionMode( handles, varargin )
%m = establishInteractionMode( m, varargin )
%   Set the interaction mode.  If the current mode is compatible with the
%   new mode, it should be updated as necessary with the extra arguments.
%   Otherwise, it should be replaced by the new mode.

    if isempty(handles.mesh)
        return;
    end
    
    mousemode = getMouseModeFromGUI( handles );
    fprintf( 1, 'establishInteractionMode %s\n', mousemode );
    switch mousemode
        case 'morpheditmodeMenu:Fix'
            clampedVxs = find( handles.mesh.morphogenclamp( :, varargin{1} )==1 );
            handles = updateSelection( handles, [], [], clampedVxs, 'replace' );
        case 'mouseeditmodeMenu:Fix nodes'
            nodes = findConstrainedNodes( handles.mesh, getFixedMode( handles ) );
            handles = updateSelection( handles, [], [], nodes, 'replace' );
        case 'mouseeditmodeMenu:Locate node'
            if handles.mesh.globalDynamicProps.locatenode==0
                selnodes = [];
            else
                selnodes = [handles.mesh.globalDynamicProps.locatenode];
            end
            handles = updateSelection( handles, [], [], selnodes, 'replace' );
        case 'mouseCellModeMenu:Add cell'
        case 'mouseCellModeMenu:Delete cell'
        otherwise
            % Nothing.
    end
end

function nodes = findConstrainedNodes( m, dfs )
    if isVolumetricMesh(m)
        a = m.fixedDFmap;
    else
        a = m.fixedDFmap(1:2:end,:) | m.fixedDFmap(2:2:end,:);  % Only valid for old-style meshes.
    end
    a = a(:,1) + 2*a(:,2) + 4*a(:,3);
    v = dfs.x + 2*dfs.y + 4*dfs.z;
    nodes = find( a==v );
end
