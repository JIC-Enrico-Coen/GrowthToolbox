function handles = addProjectsMenu( handles, projectsDir, readonly, callback )
%handles = addProjectsMenu( handles, projectsDir, readonly, callback )
%   projectsDir is a folder to be added to the Projects menu.
    if ~isempty( projectsDir )
        c = getMenuChildren( handles.projectsMenu );
        [firstProjectsMenu,lastProjectsMenu] = findProjectDirMenuItems( handles );
        dirstruct = findProjectDirs( projectsDir, 0, readonly );
        h = makeDirMenu( handles.projectsMenu, dirstruct, readonly, callback );
        if isempty(h)
            [pathname, basename] = dirparts( projectsDir );
            h = uimenu( handles.projectsMenu, ...
                        'Label', basename, ...
                        'Tag', '', ...
                        'UserData', struct( 'modeldir', projectsDir, ...
                                            'readonly', false ) );
        end
        for i=firstProjectsMenu:lastProjectsMenu
            ud = get( c(i), 'UserData' );
            if strcmp( ud.modeldir, projectsDir )
                delete( c(i) );
                set( h, 'Position', i, 'Tag', '' );
                return;
            end
        end
        set( h, 'Position', lastProjectsMenu+1, 'Tag', '' );
    end
end
