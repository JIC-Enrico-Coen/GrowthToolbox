function [first,last] = findProjectDirMenuItems( h )
    first = get( h.refreshProjectsMenu, 'Position' ) + 2;
    c = getMenuChildren( h.projectsMenu );
    last = length( c );
    if strcmp( get( c(last), 'Label' ), 'Help' )
        last = last-1;
    end
end
