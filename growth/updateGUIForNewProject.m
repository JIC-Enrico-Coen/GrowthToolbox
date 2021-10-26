function handles = updateGUIForNewProject( handles )
    if isempty(handles.mesh)
        return;
    end
    if isempty(handles.mesh.pictures)
        return;
    end
    
    handles = guidata( handles.mesh.pictures(1) );
    remakeStageMenu( handles, handles.mesh.globalDynamicProps.laststagesuffix );
    handles = refreshProjectsMenu( handles );
    % Would be faster to just insert the new project dir into the
    % Projects menu.  That would also cope with the situation where the
    % new project is not stored in any of the user project directories.
    handles = updateRecentProjects( handles );
    setMeshFigureTitle( handles.output, handles.mesh );
    if handles.mesh.globalProps.mgen_interactionName
        set( handles.mgenInteractionName, 'String', handles.mesh.globalProps.mgen_interactionName );
    else
        set( handles.mgenInteractionName, 'String', '(none)' );
    end
    guidata( handles.mesh.pictures(1), handles );
end