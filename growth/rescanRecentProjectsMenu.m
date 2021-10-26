function rescanRecentProjectsMenu( handles )
    c = get( handles.recentprojectsMenu, 'Children' );
    for i=1:length(c)
        ud = get( c(i), 'UserData' );
        if isfield( ud, 'modeldir' )
            is = isGFtboxProjectDir( ud.modeldir );
            set( c(i), 'Enable', boolchar( is, 'on', 'off' ) );
        end
    end

