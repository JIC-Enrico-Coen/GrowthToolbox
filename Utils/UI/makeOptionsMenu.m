function h = makeOptionsMenu( varargin )
%h = makeOptionsMenu( parentmenu, varargin )
%h = makeOptionsMenu( parentmenu, menuposition, varargin )
%h = makeOptionsMenu( menuposition, varargin )
%   Given a set of option descriptions, make a menu allowing them to be
%   set.
%
%   The first few arguments are option-value pairs. The options are:
%
%   'Parent'  Either a figure handle or a menu handle. In the former case
%       the new menu will be added to the menu bar of the figure. In the
%       latter it will either be a submenu item on the given menu, or the
%       options will also be inserted into that menu instead of into a
%       single submenu.
%
%   'Name'  If nonempty, a menu of this name will be created under the
%       Parent object, which will have one item for each option. If empty
%       or not supplied, the option menu items will be inserted
%       consecutively into the Parent object.
%
%   'Position'  Where the new menu is to appear in its parent, or where the
%       new items are to be inserted. 1 means it becomes the first item, 2
%       the second, etc. -1 means the last item, -2 the last but one, etc.
%       The default is -1.
%
%   'Recents'  For options that can take any value, the maximum number of
%       recently used values to retain. Defaults to 10. Use Inf to retain
%       arbitrarily many recent values.
%
%   'Callback'  This is the function that will be called in response to any
%       selection in this menu. (It is actually called indirectly, from the
%       real callback.) If omitted, no action will be taken. It should be
%       a function of one argument, which will be the menu item associated
%       with the option that was changed. It should look in that object's
%       UserData property for the field 'value', which contains the new
%       value of that option. Other fields of UserData which it may find
%       useful are 'previousvalue' (the value of 'value' before this menu
%       operation) and 'values' (the list of permissible values, or empty
%       if all values are allowed).
%
%   After these options, the remaining arguments are in groups of four:
%   MENUNAME, INTERNALNAME, VALUES, INITVALUE.
%
%   MENUNAME is the name that appears in the menu.
%
%   INTERNALNAME is the name used as the tag of this menu item. This must
%       be a valid Matlab field name.
%
%   VALUES is an array (numeric or cell) of possible values for this item.
%   If this is empty, all values are allowed.
%
%   INITVALUE is the initially selected value.
%
%   How the menu item behaves depends on what sort of values are given to
%   it.
%
%   If INITVALUE is logical and VALUES is anything but a cell array of at
%   least two strings, then VALUES will be ignored. The item will have no
%   submenu. Its value si a boolean, indicated by a checkmark.
%
%   If INITVALUE is logical and VALUES is a cell array of of at least two
%   strings, then only the first two elements of VALUES will be used. They
%   will represent true and false respectively.
%
%   If VALUES is a cell array of strings or an array of numbers, then the
%   menu item will have a submenu with these strings or numbers as their
%   names, in the order that they are listed. INITVALUE but be in the list.
%   The menu item that shows INITVALUE will have a checkmark.
%
%   If VALUES is empty, then it will have a submenu which initially will
%   have two items separated by a separator line. The first will show
%   INITVALUE, and the second will bring up a dialog for the user to select
%   a new value. After selecting a new value, it will be placed at the head
%   of the submenu, the initial value will be the second item, and the
%   command to bring up the dialog will now be the third item. Up to 10
%   recently selected values will be available in this way.
%
%   The currently selected value for each menu item is stored in its
%   UserData.value field.

    if nargin==0
        return;
    end
    parent = [];
    menuname = '';
    menuposition = -1;
    DEFAULT_RECENTS = 10;
    recents = DEFAULT_RECENTS;
    callback = @defaultUserCallback;
    curargi = 1;
    while true
        if curargi > nargin()
            return;
        end
        optionname = varargin{curargi};
        optionvalue = varargin{curargi+1};
        switch optionname
            case 'Parent'
                parent = optionvalue;
            case 'Name'
                menuname = optionvalue;
            case 'Position'
                menuposition = optionvalue;
            case 'Recents'
                recents = max( 1, optionvalue );
            case 'Callback'
                callback = optionvalue;
            otherwise
                break;
        end
        curargi = curargi+2;
    end
    
    % There must be a parent menu or figure to add the options to.
    if isempty(parent)
        return;
    end
    
    inline = isempty( menuname );
    
    % If the options are to be inserted into a new submenu, that submenu
    % must be given a name.
    if isempty( menuname ) && ~inline
        return;
    end
    
    % This procedure recognises negative numbers as menu positions counting
    % from the end, but Matlab does not. Therefore convert negative numbers
    % into proper indexes.
    menuposition = convertMenuPosition( parent, menuposition );
    
    % Create the menu and assign its handle to h.
    if inline
        h = parent;
    else
        h = uimenu( parent, 'Text', menuname );
        if menuposition ~= -1
            h.Position = menuposition;
        end
        menuposition = 1;
    end
    
    while curargi <= nargin-3
        menuname = varargin{ curargi };
        internalname = varargin{ curargi+1 };
        values = varargin{ curargi+2 };
        initvalue = varargin{ curargi+3 };
        ud = struct( 'value', initvalue, 'previousvalue', [], 'Callback', callback );
        ud.values = values;
        h1 = uimenu( h, 'Text', menuname, 'Tag', internalname, 'UserData', ud );
        if menuposition ~= -1
            h1.Position = menuposition;
        end
        isCheckmarkItem = false;
        nv = numel(values);
        if islogical( initvalue )
            if numel( values ) < 2
                set( h1, 'Checked', boolchar( initvalue, 'on', 'off' ), 'MenuSelectedFcn', @optionMenuCallback );
                h1.UserData.values = [true false];
                isCheckmarkItem = true;
            else
                if ~iscell( values )
                    values = num2cell( values );
                end
                if islogical( values{1} )
                    values = { 'True', 'False' };
                elseif isnumeric( values{1} )
                    values = { num2str( values{1} ), num2str( values{2} ) };
                end
                valuenames = values([1 2]);
                values = [true false];
            end
        elseif iscell( values )
            valuenames = values;
        elseif isnumeric( values )
            valuenames = cell( 1, nv );
            for i=1:nv
                valuenames{i} = num2str( values(i) );
            end
        else
            valuenames = values;
        end
        
        if ~isCheckmarkItem
            if nv > 0
                if ~iscell( values )
                    values = num2cell( values );
                end
                for i=1:nv
                    v = values{i};
                    h2 = uimenu( h1, 'Text', valuenames{i}, 'UserData', struct( 'value', v ), 'MenuSelectedFcn', @optionMenuCallback );
                    if ischar(v)
                        checkMenuItem( h2, strcmp( v, initvalue ) );
                    else
                        checkMenuItem( h2, v==initvalue );
                    end
                end
            else
                % All values of the option (of the right type) are valid.
                % The submenu needs to initially have two items: the initial value, and a
                % command to bring up a dialog to choose a new value.

                uimenu( h1, 'Text', num2str(initvalue), 'UserData', struct( 'value', initvalue ), 'Checked', 'on', 'MenuSelectedFcn', @optionMenuCallback );
                makeOtherItem( h1, struct( 'recents', recents ) );
            end
        end
        
        curargi = curargi+4;
        menuposition = menuposition+1;
    end
end

function makeOtherItem( parent, ud )
	uimenu( parent, 'Text', 'Other...', 'MenuSelectedFcn', @otherValueMenuCallback, 'Separator', true, 'UserData', ud );
end

function otherValueMenuCallback( hObject, ~ )
%     fprintf( 1, 'otherValueMenuCallback\n' );
    
    % Put up a dialog to get a value v, with the name of the parent menu as a
    % prompt. If the dialog is cancelled, return.
    
    ph = hObject.Parent;
    if isfloat( ph.UserData.value )
        [value,ok] = askForFloat( ph.Text, '', ph.UserData.value );
    elseif isinteger( ph.UserData.value )
        [value,ok] = askForInt( ph.Text, '', ph.UserData.value );
    elseif ischar( ph.UserData.value )
        [value,ok] = askForString( ph.Text, '', ph.UserData.value );
    else
        ok = false;
    end
    
    if ~ok
        return;
    end
    
    
    % Install v in the recent values list.
    submenus = findobj( get( ph, 'Children' ), 'flat', 'Type', 'uimenu' );
    isthis = false;
    for i=1:length(submenus)
        if (submenus(i) ~= hObject) && isfield( submenus(i).UserData, 'value' )
            if ischar(value)
                isthis = strcmp( submenus(i).UserData.value, value );
            else
                isthis = submenus(i).UserData.value==value;
            end
            if isthis
%                 fprintf( 1, 'Moving item %d, position %d, to position 1.\n', i, submenus(i).Position );
                set( submenus(i), 'Position', 1 );
            end
            checkMenuItem( submenus(i), isthis );
            if isthis
                for j=(i+1):length(submenus)
                    checkMenuItem( submenus(j), false );
                end
                break;
            end
        end
    end
    
    if ~isthis
        if isfinite( hObject.UserData.recents )
            positions = [ submenus.Position ];
            maxpos = max( positions );
            deletions = (positions >= hObject.UserData.recents) & (positions ~= maxpos);
            delete( submenus( deletions ) );
        end
        h2 = uimenu( ph, 'Text', num2str(value), 'UserData', struct( 'value', value ), 'Checked', 'on', 'MenuSelectedFcn', @optionMenuCallback );
        h2.Position = 1;
    end
    
%     for i=1:length(ph.Children)
%         fprintf( 1, 'Before fix: Other submenu text ''%s'', position %d\n', get( ph.Children(i), 'Text' ), get( ph.Children(i), 'Position' ) );
%     end
    
    callbackmenu = hObject.Parent;
    fixOtherItem( ph );
    
%     for i=1:length(ph.Children)
%         fprintf( 1, 'After fix: Other submenu text ''%s'', position %d\n', get( ph.Children(i), 'Text' ), get( ph.Children(i), 'Position' ) );
%     end
    
    callbackmenu.UserData.previousvalue = callbackmenu.UserData.value;
    callbackmenu.UserData.value = value;
    if isfield( callbackmenu.UserData, 'Callback' ) && ~isempty( callbackmenu.UserData.Callback )
        callbackmenu.UserData.Callback( callbackmenu );
    end
end

function optionMenuCallback( hObject, ~ )
%     fprintf( 1, 'optionMenuCallback %s\n', hObject.Text );
    
    ph = hObject.Parent;
    if islogical( hObject.UserData.value ) && isfield( hObject.UserData, 'previousvalue' )
        % Checkmark menu item.
        hObject.UserData.previousvalue = hObject.UserData.value;
        hObject.UserData.value = ~hObject.UserData.value;
        set( hObject, 'Checked', boolchar( hObject.UserData.value, 'on', 'off' ) );
        callbackmenu = hObject;
    else
        % Option values submenu.
        submenus = findobj( get( ph, 'Children' ), 'flat', 'Type', 'uimenu' );
        for i=1:length(submenus)
            checkMenuItem( submenus(i), submenus(i)==hObject );
        end
        ph.UserData.previousvalue = ph.UserData.value;
        ph.UserData.value = hObject.UserData.value;
        if isempty( ph.UserData.values )
            set( hObject, 'Position', 1 );
        end
        callbackmenu = hObject.Parent;
    
%     for i=1:length(ph.Children)
%         fprintf( 1, 'Before fix: Other submenu text ''%s'', position %d\n', get( ph.Children(i), 'Text' ), get( ph.Children(i), 'Position' ) );
%     end
%     
%     fixOtherItem( ph );
%     
%     for i=1:length(ph.Children)
%         fprintf( 1, 'After fix: Other submenu text ''%s'', position %d\n', get( ph.Children(i), 'Text' ), get( ph.Children(i), 'Position' ) );
%     end
    end
    
    if isfield( callbackmenu.UserData, 'Callback' ) && ~isempty( callbackmenu.UserData.Callback )
        callbackmenu.UserData.Callback( callbackmenu );
    end
end

function position = convertMenuPosition( parent, position )
    if position ~= -1
        submenus = findobj( get( parent, 'Children' ), 'flat', 'Type', 'uimenu' );
        numsubmenus = length( submenus );
        if position < 0
            position = numsubmenus + 1 + position;
        end
        position = trimnumber( 1, position, numsubmenus );
    end
end

function defaultUserCallback( h )
    v = h.UserData.value;
    pv = h.UserData.previousvalue;
    fprintf( 1, '%s: v %s, pv %s\n', h.Tag, num2str(v), num2str(pv) );
end

function fixOtherItem( ph )
% The purpose of this procedure is to force the "Other..." menu item to the
% end of teh menu. For some reason (Matlab bug) adding a menu item or
% changing the order of the other menu items bring the "Other..." item up
% to the top, even though its place in the children list and its 'Position'
% attribure say that it is at the bottom.
%
% The only way we have found of rectifying this is to delete the item and
% recreate it.

    nc = length(ph.Children);
    s = get( ph.Children, 'Text' );
    for i=1:nc
        if strcmp( s{i}, 'Other...' )
%             fprintf( 1, 'Found Other... at index %d position %d, it said position %d. Remaking.\n', ...
%                 i, length(s)+1-i, ph.Children(i).Position );
            ud = ph.Children(i).UserData;
            delete( ph.Children(i) );
            makeOtherItem( ph, ud );
%             ph.Children(i).Position = 1;
%             ph.Children(i).Position = length(ph.Children);
%             newindexing = [i, 1:(i-1), (i+1):nc];
%             ph.Children = ph.Children( newindexing );
            return;
        end
    end
end

