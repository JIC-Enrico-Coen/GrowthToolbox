function hadhighlight = setMenuHighlight( menuhandle, sethighlight )
%hadhighlight = setMenuHighlight( menuhandle, sethighlight )
% Highlight or dehighlight a menu item.  If it has no children do this by
% setting or removing the checkmark.  If it has children, do this by adding
% or removing the string '* ' at the beginning of the menu label.  We do
% this because checkmarks cannot be applied to menu items that have
% children.  The 'Checked' attribute can be set but has no visual effect.
%
% We cannot do highlighting by changing the text style or colour of a menu
% or menu item, because Matlab does not support it, and the unsupported way
% of doing it (by using HTML in the label) works only when menus are
% implementd by Java Swing, which at least on Mac OS they are not.

    if isempty( get( menuhandle, 'Children' ) )
        hadhighlight = strcmp( get( menuhandle, 'Checked' ), 'on' );
        if hadhighlight ~= sethighlight
%             fprintf( 1, 'setMenuHighlight: checkmark %s\n', ...
%                 boolchar( sethighlight, 'on', 'off' ) );
            set( menuhandle, 'Checked', boolchar( sethighlight, 'on', 'off' ) );
        end
    else
        [l,ok] = tryget( menuhandle, 'Label' );
        if ~ok
            % Does not have a label property.  Silently give up.
            return;
        end
        hadhighlight = ~isempty( regexp( l, '^\* ' ) );
        if hadhighlight ~= sethighlight
%             fprintf( 1, 'setMenuHighlight: asterisk %s\n', ...
%                 boolchar( sethighlight, 'on', 'off' ) );
            if sethighlight
                set( menuhandle, 'Label', [ '* ', l ] );
            else
                set( menuhandle, 'Label', l(3:end) );
            end
        end
    end
end
