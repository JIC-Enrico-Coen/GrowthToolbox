function hDialog = makeGeneralDialog( name, mode, notifyhandle, ...
    userdata, dlgprops, varargin )

    if (nargin < 5) || isempty(dlgprops)
        dlgprops = {};
    end
    if (nargin < 4) || isempty(userdata)
        userdata = {};
    end
    if (nargin < 3) || isempty(notifyhandle)
        notifyhandle = -1;
    end
    if (nargin < 2) || isempty(mode)
        mode = 'normal';
    end
    if (nargin < 1) || isempty(name)
        name = 'Test';
    end
    userdata = struct(userdata{:});
    
    hDialog = dialog('Name',name, ...
        'WindowStyle',mode, ...
        'UserData', userdata, ...
        'Visible', 'off', ...
        'Tag', 'generaldialog', ...
        'ButtonDownFcn', @dlgButtonDownFcn, ...
        'CloseRequestFcn', @dlgClose, ...
        'KeyPressFcn', @dlgKeyPressFcn, ...
        dlgprops{:} );
    dlgPos = get( hDialog, 'Position' );
    dfltMargin = 10;
    dfltItemHeight = 25;
    userdata = defaultFromStruct( userdata, struct( ...
        'margin', dfltMargin, ...
        'horizSep', dfltMargin, ...
        'itemWidth', 60, ...
        'itemHeight', dfltItemHeight, ...
        'currentX', dfltMargin, ...
        'currentY', dlgPos(4) - dfltMargin - dfltItemHeight ) );
    set( hDialog, 'UserData', userdata );
  % get(hDialog)

    % Set up dialog items.
    setUpDialogItems( hDialog, varargin{:} );
    hh = guidata(hDialog);
    hh.notified = notifyhandle;
    hh.notifierFcn = @notifier;
    guidata( hDialog, hh );
   
    set( hDialog, 'Visible', 'on' );
end

function notifier( h )
    gd = guidata(h);
    if ishandle(gd.notified)
        gdn = guidata( gd.notified );
        if ~isempty(gdn)
            lastChangeFields = fieldnames(gd.lastChange);
            tagfield = lastChangeFields{1};
            notifydata = struct( 'Dialog', getRootHandle(h), ...
                                 'Tag', tagfield, ...
                                 'Value', gd.lastChange.(tagfield) );
            if ~isfield(gdn,'dlgchanges')
                gdn.dlgchanges = struct([]);
            end
            gdn.dlgchanges = [ gdn.dlgchanges, notifydata ];
            guidata( gd.notified, gdn );
            if ~getFlag( gdn, 'runFlag' )
                gdn.processdlgqueue( gd.notified );
            end
        end
    end
end

function setUpDialogItems( hDialog, varargin )
  % dlgdata = struct();
    for i=1:length(varargin)
        h = addItem( hDialog, varargin{i} );
     %  dlgdata.(get(h,'Tag')) = get(h,'Value');
    end
    hh = guihandles(hDialog);
    dlgdata = collectDialogData( hh );
    hh.output = dlgdata;
    hh.lastChange = struct();
    guidata( hDialog, hh );
end

function itemHandle = addItem( hDialog, item )
    ud = get( hDialog, 'UserData' );
    hp = get( hDialog, 'Position' );
    dlgWidth = hp(3)
    itemStruct = struct(item{:});
    itemStruct = defaultfields( itemStruct, 'FontSize', 10, 'Units', 'pixels' );
    if isfield(itemStruct,'Position')
        pos = itemStruct.Position;
        if length(pos) ~= 4
            itemStruct = rmfield( itemStruct, 'Position' );
        end
    else
        pos = [];
    end
    if length(pos) ~= 4
        if isempty(pos)
            pos = [ud.itemWidth ud.itemHeight];
        end
        if length(pos)==2
            pos = [ud.currentX ud.currentY pos([1 2])];
        end
    end
    if pos(1) + pos(3) > dlgWidth - ud.margin
        ud.currentX = ud.margin;
        ud.currentY = ud.currentY - ud.itemHeight;
        fprintf( 1, 'New line: %d %d\n', ud.currentX, ud.currentY );
        if ud.currentY < ud.margin
            fprintf( 1, 'Items do not fit into dialog.\n' );
            item
        end
        pos([1 2]) = [ud.currentX ud.currentY];
    end
    ud.currentX = pos(1) + pos(3) + ud.horizSep;
    set( hDialog, 'UserData', ud );
    itemHandle = uicontrol(hDialog, itemStruct);
    set(itemHandle, 'Position', pos);
    switch itemStruct.Style
        case 'checkbox'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'edit'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'listbox'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'popupmenu'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'pushbutton'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'radiobutton'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'slider'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        case 'text'
        case 'togglebutton'
            set( itemHandle, 'Callback', @dlgItemCallbackFcn );
        otherwise
    end
  % tag = get(itemHandle,'Tag');
  % extent = get(itemHandle,'Extent')
  % pos = get(itemHandle,'Position');
  % fprintf( 1, '%s [%d %d %d %d]\n', tag, pos );
end

function dlgKeyPressFcn( h, varargin )
    % Ignore clicks on the background of the dialog.
%   fprintf( 1, 'dlgKeyPressFcn %f and %d more arguments.\n', ...
%       h, length(varargin) );
%   varargin{:}
    return;
end

function dlgButtonDownFcn( h, varargin )
end

function dlgItemCallbackFcn( h, varargin )
    [tag,value] = getDialogItemData( h )
    if ~isempty(tag)
        gd = guidata( h );
        gd.output.(tag) = value;
        gd.lastChange = struct(tag,value);
        guidata(h,gd);
        fprintf( 1, '%s:', tag ); value
        notifierFcn = gd.notifierFcn;
        if isa(notifierFcn,'function_handle')
            notifierFcn( h );
        end
    end
end

function dlgClose( h, varargin )
%   fprintf( 1, 'dlgClose %f and %d more arguments.\n', ...
%       h, length(varargin) );
    ud = get(h,'UserData');
    ud.closeRequest = 1;
    set(h,'UserData',ud);
    closereq;
end
