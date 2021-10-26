function v = valueShowHideMenuItem( h )
%v = valueShowHideMenuItem( h )
%   For a menu item having a label of the form 'Show ...' or 'Hide ...',
%   return 0 if the label is 'Show ...', otherwise 1.  This may seem to be
%   the opposite of what one would expect, but remember that when the menu
%   command says 'Hide', the last menu command that the user performed was
%   'Show', and vice versa.
%
%   See also: setShowHideMenuItem, toggleShowHideMenuItem.

    if regexp( get( h, 'Label' ), '^Show ' )
        v = 0;
    else
        v = 1;
    end
end
