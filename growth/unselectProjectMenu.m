function unselectProjectMenu( handles )
    ud = get( handles.projectsMenu, 'Userdata' );
    if ~isempty( ud ) && isfield( ud, 'defaultprojectitem' ) && ishandle( ud.defaultprojectitem )
        selectProjectMenu( ud.defaultprojectitem, false );
        ud = rmfield( ud, 'defaultprojectitem' );
        set( handles.projectsMenu, 'Userdata', ud );
    end

