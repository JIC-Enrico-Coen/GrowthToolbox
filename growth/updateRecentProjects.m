function handles = updateRecentProjects( handles )
%handles = updateRecentProjects( handles )
%   A project has just been loaded.  Add its project directory to the
%   Recent Projects menu and save the GFtbox config. Also weed out any
%   nonexistent projects from the Recent Projects menu.

    MAX_RECENTS = 20;

    % I am not sure what this is for.
    c = get( handles.recentprojectsMenu, 'Children' );
    if (length(c)==1) && isempty( get( c, 'UserData' ) )
        delete( c );
        c = [];
    end
    
    % Find and delete all invalid items.
    isvalid = false( length(c), 1 );
    for i=1:length(c)
        ud = get( c(i), 'UserData' );
        if ~isempty(ud)
            isvalid(i) = isGFtboxProjectDir( ud.modeldir );
        else
        end
    end
    if any(~isvalid)
        cv = c(isvalid);
        cnv = c(~isvalid);
        delete(cnv);
        c = cv;
    end
    
    % If there is no current project, there is no more to do.
    projectdir = getModelDir( handles.mesh );
    if isempty( projectdir )
        return;
    end
    
    % I am not sure why we turn the separator off before modifying the
    % menu, then turn it back on. This may have been something to do with
    % the old Matlab/OSX bug mentioned below.
    set( handles.recentprojectsMenu, 'Separator', 'off' );
    
    % If the current project is in the menu, move it to the top.
    for i=1:length(c)
        ud = get( c(i), 'UserData' );
        if ~isempty(ud) && strcmp( ud.modeldir, projectdir )
            set( c(i), 'Position', 1 );
            drawnow;  % Workaround for Matlab R2011a/MacOS bug.
            set( handles.recentprojectsMenu, 'Separator', 'on' );
            return;
        end
    end
    
    % If the current project was not in the menu, add it at the top.
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
