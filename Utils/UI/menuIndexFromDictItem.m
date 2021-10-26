function [menuIndex,found] = menuIndexFromDictItem( dictionary, dictItem, menu )
%menuIndex = menuIndexFromDictItem( dictionary, dictItem, menu )
%   Given a dictionary and an item in that dictionary (as either an index
%   or a name), find the index of that item in the menu, if it occurs
%   there, otherwise return 1.  The FOUND output argument indicates whether
%   it was found.

    
    dictItemName = index2Name( dictionary, dictItem );
    menuIndex = getMenuIndexFromLabel( menu, dictItemName );
    found = menuIndex ~= 0;
    if ~found
        menuIndex = 1;
    end
end
