function updateProjectMenuHighlights( handles, selectedDir )
%updateProjectMenuHighlights( handles, selectedDir )
%   Update the peoject menu highlights so the the path leading to
%   selectedDir is highlighted and all other items are unhighlighted.

    highlighted = updateSomeProjectMenuHighlights( ...
                    get( handles.recentprojectsMenu, 'Children' ), ...
                    selectedDir );
    setMenuHighlight( handles.recentprojectsMenu, highlighted );
    c = getMenuChildren( handles.projectsMenu );
    [firstProjectsMenu,lastProjectsMenu] = findProjectDirMenuItems( handles );
    updateSomeProjectMenuHighlights( c(firstProjectsMenu:lastProjectsMenu), selectedDir );
end

function highlighted = updateSomeProjectMenuHighlights( menuitems, selectedDir )
    highlighted = false;
    for i=1:length(menuitems)
        menuitem = menuitems(i);
        ud = get( menuitem, 'UserData' );
        if isempty(ud)
            % Compression node.
            highlighted = updateSomeProjectMenuHighlights( ...
                              get( menuitem, 'Children' ), selectedDir );
            setMenuHighlight( menuitem, highlighted );
        elseif isstruct(ud) && isfield( ud, 'modeldir' ) && ~isempty( ud.modeldir )
            setprefix = isPathPrefix( ud.modeldir, selectedDir );
            highlighted = highlighted || setprefix;
            hadprefix = setMenuHighlight( menuitem, setprefix );
            if hadprefix || setprefix
                if setprefix
                    updateSomeProjectMenuHighlights( get( menuitem, 'Children' ), selectedDir );
                else
                    updateSomeProjectMenuHighlights( get( menuitem, 'Children' ), '' );
                end
            end
        else
            % Shouldn't happen -- invalid userdata.  Ignore.
            setMenuHighlight( menuitem, false );
        end
    end
end
