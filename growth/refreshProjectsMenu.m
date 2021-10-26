function handles = refreshProjectsMenu( handles )
    wasBusy = setGFtboxBusy( handles, true );
    c = getMenuChildren( handles.projectsMenu );
    [firstProjectsMenu,lastProjectsMenu] = findProjectDirMenuItems( handles );
    for i=firstProjectsMenu:lastProjectsMenu
        ud = get( c(i), 'UserData' );
        if isfield( ud, 'modeldir' )
            handles = addProjectsMenu( handles, ud.modeldir, ud.readonly, @projectMenuItemCallback );
        end
    end
    rescanRecentProjectsMenu( handles );
    c = getMenuChildren( handles.projectsMenu );
    forceMenuSeparator( c(end) );
    handles = selectDefaultProjectsMenu( handles, getModelDir( handles.mesh ) );
    setGFtboxBusy( handles, wasBusy );
end
