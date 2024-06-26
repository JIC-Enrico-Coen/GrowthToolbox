function [s,links] = buildRSSSstructdialog( s, parent, bbox, path, initvals, links )
%[s,links] = buildRSSSstructdialog( s, parent, bbox, path, initvals, links )
%   Create a dialog laid out according to the description in s, a data
%   structure parsed from a layout file.

    if nargin < 4
        path = [];
    end
    if nargin < 5
        initvals = struct();
    end
    if nargin < 6
        links = cell(0,2);
    end
    % Callbacks:
    % figure:
    %   CreateFcn, CloseRequestFcn, KeyPressFcn, KeyReleaseFcn, ResizeFcn,
    %   WindowButtonDownFcn	WindowButtonMotionFcn	WindowButtonUpFcn
    %   WindowKeyPressFcn	WindowKeyReleaseFcn	WindowScrollWheelFcn
    % All uicontrols:
    %   Callback, ButtonDownFcn, CreateFcn, DeleteFcn, KeyPressFcn
    switch s.type
        case 'axes'
            s.handle = axes( 'Parent', parent, 'Units', 'pixels', ...
                'Tag', s.attribs.tag, ...
                'Visible', s.attribs.visible ...
                );
            setIfPosNonempty( s.handle, 'FontSize', s.attribs, 'fontsize' );
            setIfPosNonempty( s.handle, 'FontWeight', s.attribs, 'fontweight' );
            setIfPosNonempty( s.handle, 'LineWidth', s.attribs );
            setIfPosNonempty( s.handle, 'YAxisLocation', s.attribs );
            if isfield( s.attribs, 'string' )
                title( s.handle, s.attribs.string );
            end
            for i=1:length(s.children)
                [s.children{i},links] = buildRSSSstructdialog( ...
                    s.children{i}, s.handle, [], [], initvals, links );
            end
            xlabelChild = findChild( s, 'xlabel' );
            if ~isempty( xlabelChild )
                xlabel_handle = xlabel( s.handle, xlabelChild.attribs.string );
                setHandleAttribs( xlabel_handle, xlabelChild.attribs );
            end
            if isfield( s.attribs, 'xtitle' )
                xlabel( s.handle, s.attribs.xtitle );
            end
            if isfield( s.attribs, 'ytitle' )
                ylabel( s.handle, s.attribs.ytitle );
            end
            if isfield( s.attribs, 'ztitle' )
                zlabel( s.handle, s.attribs.ztitle );
            end
        case 'xlabel'
%             s.handle = xlabel( parent, s.attribs.string );
        case 'figure'
            s.handle = getFigure( 'Visible', 'off', ...
                               'Resize', s.attribs.resize, ...
                               'MenuBar', s.attribs.menubar, ...
                               'Position', [0 0 1 1], ...
                               'Units', 'pixels', ...
                               'Tag', s.attribs.tag, ...
                               'Name', s.attribs.string, ...
                               'IntegerHandle', 'off', ...
                               'HandleVisibility', s.attribs.handlevisibility, ...
                               'NumberTitle', 'on', ...
                               'CreateFcn', s.attribs.createfcn, ...
                               'KeyPressFcn', 'checkTerminationKey(gcbo)', ...
                               'CloseRequestFcn', 'closeDialog(gcbo)' );
            setIfPosNonempty( s.handle, 'IntegerHandle', s.attribs );
            setIfPosNonempty( s.handle, 'Color', s.attribs, 'color' );
            s.attribs.interiorsize = handleInteriorSize( s.handle );
            [s,links] = buildRSSSstructdialoggroup( s, s.handle, ...
                s.attribs.interiorsize + s.attribs.outermargin.*[1 1 -2 -2], ...
                s.attribs.innermargin, ...
                s.attribs.rows==1, ...
                [ path, 1 ], ...
                initvals, ...
                links);
            for i=1:length(s.menus)
                 [s.menus{i},links] = buildRSSSstructdialog( ...
                    s.menus{i}, s.handle, [], [], initvals, links );
            end
            guidata( s.handle, collectRSSShandles( s ) );
        case 'panel'
            s.handle = uipanel( 'Parent', parent, 'Units', 'pixels', ...
                'Tag', s.attribs.tag, ...
                'Title', s.attribs.string, ...
                'BorderType', s.attribs.bordertype, ...
                'FontWeight', s.attribs.fontweight, ...
                'ButtonDownFcn', s.attribs.callback );
            s.attribs.interiorsize = handleInteriorSize( s.handle );
            [s,links] = buildRSSSstructdialoggroup( s, s.handle, ...
                s.attribs.interiorsize + s.attribs.outermargin.*[1 1 -2 -2], ...
                s.attribs.innermargin, ...
                s.attribs.rows==1, ...
                [ path, 1 ], ...
                initvals, ...
                links );
        case 'colorchooser'
            s.handle = uipanel( 'Parent', parent, 'Units', 'pixels', ...
                'Tag', s.attribs.tag, ...
                'Title', '', ...
                'BorderType', 'line', ...
                'title', '', ...
                'foregroundcolor', [0 0 0], ...
                'highlightcolor', [0 0 0], ...
                'shadowcolor', [0 0 0], ...
                'bordertype', 'line', ...
                'borderwidth', 1, ...
                'ButtonDownFcn', s.attribs.callback );
            s.attribs.interiorsize = handleInteriorSize( s.handle );
%             setNaturalHandleSize( s.handle );
%             [s,links] = buildRSSSstructdialoggroup( s, s.handle, ...
%                 s.attribs.interiorsize + s.attribs.outermargin.*[1 1 -2 -2], ...
%                 s.attribs.innermargin, ...
%                 s.attribs.rows==1, ...
%                 [ path, 1 ], ...
%                 initvals, ...
%                 links );
        case 'radiogroup'
            s.handle = uibuttongroup( 'Parent', parent, 'Units', 'pixels', ...
                'Tag', s.attribs.tag, ...
                'Title', s.attribs.teststring, ...
                'BorderType', s.attribs.bordertype, ...
                'FontWeight', s.attribs.fontweight, ...
                'SelectionChangeFcn', s.attribs.SelectionChangeFcn );
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            set( s.handle, 'Title', s.attribs.string );
            s.attribs.interiorsize = handleInteriorSize( s.handle );
            [s,links] = buildRSSSstructdialoggroup( s, s.handle, ...
                s.attribs.interiorsize + s.attribs.outermargin.*[1 1 -2 -2], ...
                s.attribs.innermargin, ...
                s.attribs.rows==1, ...
                [ path, 1 ], ...
                initvals, ...
                links );
        case 'group'
            s.handle = [];
            [s,links] = buildRSSSstructdialoggroup( s, parent, ...
                bbox + s.attribs.outermargin.*[1 1 -2 -2], ...
                s.attribs.innermargin, ...
                s.attribs.rows==1, ...
                [ path, 1 ], ...
                initvals, ...
                links );
        case { 'popupmenu', 'listbox' }
            if strcmp( s.type, 'listbox' )
                if s.attribs.multiline
                    maxval = 2;
                else
                    maxval = 1;
                end
                lines = s.attribs.lines;
            else
                maxval = 1;
                lines = 1;
            end
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', s.type, ...
                'Tag', s.attribs.tag, ...
                'Max', maxval, ...
                'String', s.attribs.teststring, ...
                'FontWeight', s.attribs.fontweight, ...
                'Callback', s.attribs.callback );
            setNaturalHandleSize( s.handle, s.attribs.fontsize, lines );
            set( s.handle, 'String', s.attribs.strings );
        case 'slider'
            if strcmp( s.attribs.direction, 'horiz' )
                s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'slider', ...
                    'Min', s.attribs.min, ...
                    'Max', s.attribs.max, ...
                    'SliderStep', [s.attribs.minorstep, s.attribs.majorstep], ...
                    'Tag', s.attribs.tag, ...
                    'Callback', s.attribs.callback );
            else
                s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'slider', ...
                    'Min', s.attribs.min, ...
                    'Max', s.attribs.max, ...
                    'SliderStep', [s.attribs.minorstep, s.attribs.majorstep], ...
                    'Tag', s.attribs.tag, ...
                    'Callback', s.attribs.callback, ...
                    'Position', [20 20 20 80] );
            end
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            if isfield( s.attribs, 'link' )
                links(end+1,:) = { s.attribs.link, s.attribs.tag };
            end
        case 'text'
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'text', ...
                'Tag', s.attribs.tag, ...
                'Visible', s.attribs.visible, ...
                'String', s.attribs.teststring, ...
                'FontWeight', s.attribs.fontweight, ...
                'HorizontalAlignment', s.attribs.haligncontent, ...
                'Callback', s.attribs.callback );
            setNaturalHandleSize( s.handle, s.attribs.fontsize, s.attribs.lines );
            set( s.handle, 'String', s.attribs.string );
        case 'edit'
            if s.attribs.multiline
                maxval = 2;
            else
                maxval = 1;
            end
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'edit', ...
                'Tag', s.attribs.tag, ...
                'String', s.attribs.teststring, ...
                'FontWeight', s.attribs.fontweight, ...
                'BackgroundColor', [1 1 1], ...
                'ForegroundColor', [0 0 0], ...
                'Max', maxval, ...
                'HorizontalAlignment', s.attribs.haligncontent, ...
                'Callback', s.attribs.callback, ...
                'CreateFcn', @edittextCreateFcn );
            setNaturalHandleSize( s.handle, s.attribs.fontsize, s.attribs.lines );
            set( s.handle, 'String', s.attribs.string );
        case 'checkbox'
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'checkbox', ...
                'Tag', s.attribs.tag, ...
                'String', s.attribs.teststring, ...
                'FontWeight', s.attribs.fontweight, ...
                'Callback', s.attribs.callback, ...
                'Value', s.attribs.value );
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            set( s.handle, 'String', s.attribs.string );
        case 'radiobutton'
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'radiobutton', ...
                'Tag', s.attribs.tag, ...
                'String', s.attribs.teststring, ...
                'FontWeight', s.attribs.fontweight, ...
                'Value', s.attribs.value );
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            set( s.handle, 'String', s.attribs.string );
        case 'pushbutton'
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'pushbutton', ...
                'Tag', s.attribs.tag, ...
                'String', s.attribs.teststring, ...
                'Callback', s.attribs.callback, ...
                'FontWeight', s.attribs.fontweight );
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            set( s.handle, 'String', s.attribs.string );
        case 'togglebutton'
            s.handle = uicontrol( 'Parent', parent, 'Units', 'pixels', 'Style', 'togglebutton', ...
                'Tag', s.attribs.tag, ...
                'String', s.attribs.teststring, ...
                'Callback', s.attribs.callback, ...
                'FontWeight', s.attribs.fontweight );
            setNaturalHandleSize( s.handle, s.attribs.fontsize );
            set( s.handle, 'String', s.attribs.string );
        case 'menu'
            s.handle = uimenu( 'Parent', parent, ...
                'Tag', s.attribs.tag, ...
                'Label', s.attribs.string, ...
                'Callback', s.attribs.callback, ...
                'Separator', s.attribs.separator );
            for i=1:length(s.children)
                [s.children{i},links] = buildRSSSstructdialog( ...
                    s.children{i}, s.handle, [], [], initvals, links );
            end
        otherwise
            fprintf( 1, 'Object type "%s" not implemented.\n', s.type );
    end
    if isfield( s.attribs, 'singlechild' ) && s.attribs.singlechild
        for i=1:length(s.children)
            if i ~= s.attribs.selectedchild
                h = s.children{i}.handle;
                if ishandle( h )
                    set( h, 'Visible', 'off' );
                end
            end
        end
    end
end

function h = collectRSSShandles( s, h )
    if nargin < 2
        h = struct();
    end
    if ishandle( s.handle )
        tag = get( s.handle, 'Tag' );
        if ~isempty(tag)
            h.(tag) = s.handle;
        end
    end
    for i=1:length( s.children )
        h = collectRSSShandles( s.children{i}, h );
    end
end

function setNaturalHandleSize( h, fontsize, lines )
    if nargin < 2
        fontsize = 0;
    end
    if fontsize > 0
        tryset( h, 'FontSize', fontsize );
    else
        try
            fontsize = get( h, 'FontSize' );
        catch e %#ok<NASGU>
            fontsize = 10;
        end
    end
    if nargin < 3
        lines = 1;
    end
    pos = get( h, 'Position' );
    try
        ext = get( h, 'Extent' );
    catch e %#ok<NASGU>
        return;
    end
    t = get(h,'Type');
    if strcmp( t, 'uicontrol' )
        t = get(h,'Style');
    end
    switch t
        case 'checkbox'
            pos([3 4]) = [ ext(3)+20, ext(4) ];
        case 'radiobutton'
            pos([3 4]) = [ ext(3)+20, ext(4) ];
        case { 'pushbutton', 'togglebutton' }
            pos([3 4]) = [ ext(3)+6, max( ext(4)+3, 24 ) ];
        case 'listbox'
            pos([3 4]) = [ ext(3)+65, ext(4)+3 ];
        case 'popupmenu'
            pos([3 4]) = [ ext(3)+3*(ext(4)+3)+2*fontsize, ext(4)+3 ];
        case 'edit'
            pos([3 4]) = [ ext(3)+6, ext(4)+6 ];
        case 'text'
            pos([3 4]) = ext([3 4]);
        case 'slider'
            if pos(3) > pos(4)
                pos([3 4]) = max( pos([3 4]), [80 20] );
            else
                pos([3 4]) = max( pos([3 4]), [20 80] );
            end
        otherwise
            fprintf( 1, 'setNaturalHandleSize: uncaught case ''%s''.\n', t );
    end
    if lines > 1
        lineheight = min( fontsize*1.5, pos(4) );
        pos(4) = lineheight*lines;
    end
    set( h, 'Position', pos );
end

function bbox1 = positionWithinBbox( sz, bbox, valign, halign )
    bbox1([1 3]) = positionWithinInterval( sz(1), bbox([1 3]), halign );
    bbox1([2 4]) = positionWithinInterval( sz(2), bbox([2 4]), valign );
end

function int2 = positionWithinInterval( len, interval, align )
    switch align
        case { 'top', 'right' }
            int2 = [ interval(1) + interval(2) - len, len ];
        case { 'bottom', 'left' }
            int2 = [ interval(1), len ];
        case { 'centre', 'center' }
            int2 = [ interval(1) + (interval(2)-len)/2, len ];
        otherwise
            int2 = interval;
    end
end

function [s,links] = buildRSSSstructdialoggroup( s, parent, bbox, margin, horizontal, path, initvals, links )
    numitems = length(s.children);
    if length(margin)==1
        margin = [margin margin];
    end
    if horizontal
        itemsize = [ (bbox(3)+margin(1))/numitems - margin(1), bbox(4) ];
        itemstep = [ itemsize(1)+margin(1), 0 ];
        childbbox = [bbox([1 2]) itemsize];
    else
        itemsize = [ bbox(3), (bbox(4)+margin(2))/numitems - margin(2) ];
        itemstep = [ 0, -itemsize(2)-margin(2) ];
        childbbox = [bbox([1 2]) - (numitems-1)*itemstep, itemsize];
    end
    
    for i=1:numitems
        [s.children{i},links] = buildRSSSstructdialog( s.children{i}, parent, childbbox, [path i], initvals, links );
        childbbox = childbbox + [itemstep, 0, 0];
    end
end

function setIfPosNonempty( h, attribName, s, fieldname )
    if nargin < 4
        fieldname = attribName;
    end
    
    if ~isfield( s, fieldname )
        return;
    end
    
    value = s.(fieldname);
    if isempty( value )
        return;
    end
    
    if (isnumeric(value) && ((length(value) > 1) || (value > 0))) || ischar(value) || isstring(value)
        h.(attribName) = value;
    end
end

function c = findChild( s, childType )
    c = [];
    for ci=1:length(s.children)
        if strcmp( s.children{ci}.type, childType )
            c = s.children{ci};
            return;
        end
    end
end

function setHandleAttribs( h, attribs )
    if isfield( attribs, 'YAxisLocation' )
        xxxx = 1;
    end
    fns = intersect( fieldnames( h ), fieldnames( attribs ) );
    for fi=1:length(fns)
        fn = fns{fi};
        h.(fn) = attribs.(fn);
    end
end

