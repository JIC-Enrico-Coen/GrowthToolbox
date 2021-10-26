function setShowHideMenuItem( h, v )
%setShowHideMenuItem( h, v )
%   For a menu item having a label of the form 'Show ...' or 'Hide ...',
%   set it to 'Hide ...' if v is 1, otherwise 'Show ...'.
%
%   See also: toggleShowHideMenuItem, valueShowHideMenuItem.

    label = get( h, 'Label' );
    label = [ boolchar( v, 'Hide ', 'Show ' ), label(6:end) ];
    set( h, 'Label', label );
end
