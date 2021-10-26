function handles = updateRecentProjects( handles )
%handles = updateRecentProjects( handles )
%   A project has just been loaded.  Add its project directory to the
%   Recent Projects menu and save the GFtbox config.

    MAX_RECENTS = 20;

    projectdir = getModelDir( handles.mesh );
    if isempty( projectdir )
        return;
    end
    c = get( handles.recentprojectsMenu, 'Children' );
    if (length(c)==1) && isempty( get( c, 'UserData' ) )
        delete( c );
        c = [];
    end
    set( handles.recentprojectsMenu, 'Separator', 'off' );
    for i=1:length(c)
        ud = get( c(i), 'UserData' );
        if ~isempty(ud) && strcmp( ud.modeldir, projectdir )
            set( c(i), 'Position', 1 );
            drawnow;  % Workaround for Matlab R2011a/MacOS bug.
            set( handles.recentprojectsMenu, 'Separator', 'on' );
            return;
        end
    end
    uimenu( handles.recentprojectsMenu, ...
        'Label', handles.mesh.globalProps.modelname, ...
        'UserData', struct( 'modeldir', projectdir, 'readonly', false ), ...
        'Position', 1, ...
        'Callback', @recentprojectsMenuItemCallback );
    drawnow;  % Workaround for Matlab R2011a/MacOS bug.
    set( handles.recentprojectsMenu, 'Separator', 'on' );
    if length(c) > MAX_RECENTS
        p = get(c,'Position');
        delete( c( cell2mat(p) > MAX_RECENTS ) );
    end
    saveGFtboxConfig( handles );
end
