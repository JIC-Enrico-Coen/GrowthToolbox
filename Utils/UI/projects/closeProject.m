function handles = closeProject( handles )
    if isfield( handles.mesh, 'projectName' )
        handles.mesh = saveAsNewNode( handles.mesh );
        handles.mesh = rmfield( handles.mesh, 'projectName' );
    end
    handles.mesh = safermfield( handles.mesh, 'projectDirectory' );
end
