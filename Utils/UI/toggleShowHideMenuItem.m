function v = toggleShowHideMenuItem( h )
%v = toggleShowHideMenuItem( h )
%   For a menu item having a label of the form 'Show ...' or 'Hide ...',
%   switch from one state to the other.  Return 1 if the old state was
%   'Show ...', otherwise 0.
%
%   See also: setShowHideMenuItem, valueShowHideMenuItem.

    label = get( h, 'Label' );
    if regexp( label, '^Hide ' )
        label = [ 'Show ', label(6:end) ];
        v = 0;
    else
        label = [ 'Hide ', label(6:end) ];
        v = 1;
    end
    set( h, 'Label', label );
end
