function n = unstarredNameFromMenu( menu )
% Get the name of the currently selected item in the menu, stripping off
% any initial "* '.
    n = getMenuSelectedLabel(menu);
    n = regexprep( n, '^\* *', '' );
end
