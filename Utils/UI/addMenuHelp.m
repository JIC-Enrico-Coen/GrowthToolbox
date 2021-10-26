function addMenuHelp( hm, m, helptexts, separator )
%addMenuHelp( hm, m, helptexts, separator )
%   hm is a handle to a help menu, to which an item should be added to
%   provide help for the menu or menu item m.  If m is a menu item, the
%   correspomnding help menu item will bring up a dialog showing some
%   helpful text for that item.  If m is a menu (i.e. it has children),
%   then a menu will be created whose first item will be the help item for
%   m, and whose remaining items or submenus will provide the help for the
%   children of m.
%   helptexts is a struct which maps the tag of each menu or menu item to
%   its help text.  If separator is true, a separator should appear before
%   the help menu item.

    if ~ishandle(m), return; end
	mud = get( m, 'UserData' );
    if isempty(mud) || isfield( mud, 'nohelp' )
        % Do not add a help menu item for this or its children.
        return;
    end
    mtag = get( m, 'Tag' );
    c = get( hm, 'Children' );
    if isempty(c)
        tag = [ 'help_' mtag ];
        label = get( m, 'Label' );
    else
        tag = [ 'helpmenu_' mtag ];
        label = [ get( m, 'Label' ), ' Menu' ];
    end
    if isfield( helptexts, tag )
        helptext = helptexts.(mtag);
    elseif isempty(c)
        helptext = '(There is no help text for this menu item.)';
    else
        helptext = '(There is no help text for this menu.)';
    end
    newmenu = uimenu( 'Parent', hm, ...
                      'Tag', tag, ...
                      'Label', label, ...
                      'Separator', boolchar( separator, 'on', 'off' ) );
    if isempty(c)
        set( m, 'UserData', struct( 'help', newmenu ) );
        set( newmenu, ...
             'UserData', struct( 'helptext', helptext ), ...
             'Callback', @menuTooltipCallback );
    else
        firstitem = uimenu( 'Parent', newmenu, ...
                            'Label', get( m, 'Label' ), ...
                            'UserData', struct( 'helptext', helptext ), ...
                            'Tag', [ 'help_' mtag ], ...
                            'Callback', @menuTooltipCallback );
        for i=1:length(c)
            addMenuHelp( c(i), newmenu, helptexts, i==1 );
        end
    end
end

function menuTooltipCallback( hObject )
    s = get( hObject, 'UserData' );
    if isfield( s, 'helpfig' ) && ishandle( s.helpfig )
        figure(s.helpfig);
    elseif isfield( s, 'helptext' ) && ~isempty( s.helptext )
        title = regexprep( get( hObject, 'Label' ), '^help_', '' );
        s.helpfig = displayTextInDlg( title, s.helptext );
        set( hObject, 'UserData', s );
    end
end

