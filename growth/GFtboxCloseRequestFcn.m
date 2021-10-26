function GFtboxCloseRequestFcn()
    global GFtboxFigure

    fig = gcbf();
    if isempty(fig)
        % The function was not called as a callback in response to a close
        % request.  Do nothing.
        return;
    end
    
  % fprintf( 1, 'GFtboxCloseRequestFcn called.\n' );

    % The CloseRequestFcn must not be allowed to crash, otherwise the
    % user will have no way to close GFtbox.  Therefore everything it
    % does that might raise an exception is wrapped in an exception handler
    % that ignores all exceptions.
    try
        handles = guidata( fig );

        if isfield(handles,'mesh') && (~isempty(handles.mesh))
            % Save a thumbnail of the current project.
            try
                makeDefaultThumbnail( handles.mesh );
            catch e %#ok<NASGU>
            end

            % Remove the current model from the path.
            if handles.mesh.globalProps.addedToPath
                fprintf( 1, 'Removing %s from path.\n', getModelDir( handles.mesh ) );
                rmpath( getModelDir( handles.mesh ) );
            end
        end
        saveGFtboxConfig( handles );
    catch e %#ok<NASGU>
    end
   
    % Delete all floating panels.
    try
        ud = get( fig, 'Userdata' );
        if isfield( ud, 'floatingpanels' )
            fn = fieldnames( ud.floatingpanels );
            for i=1:length(fn)
                fni = fn{i};
                fph = ud.floatingpanels.(fni);
                if ishghandle( fph )
                    delete(fph);
                end
            end
        end
    catch e %#ok<NASGU>
    end
   
    % Destroy the figure.
    try
        delete( fig );
    catch e %#ok<NASGU>
    end
    GFtboxFigure = [];
end
