function handles = stopMovie( handles )
    if isfield( handles, 'mesh' ) && movieInProgress(handles.mesh)
        attemptCommand( handles, false, false, ...
            'movie', 0 );
    end
    if isfield( handles, 'movieButton' )
        set( handles.movieButton, 'String', 'Record movie...' );
    end
end
