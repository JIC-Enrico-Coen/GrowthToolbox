function s = fillRSSSdefaults( s, modal, inheritedattribs )
    s = defaultFromStruct( s, ...
            struct( 'type', '', 'children', [], 'attribs', [], 'handle', [] ) );
    if nargin >= 3
        s.attribs = defaultFromStruct( s.attribs, inheritedattribs );
    else
        inheritedattribs = struct();
    end
    s.attribs = defaultFromStruct( s.attribs, ...
        struct( 'margin', [5 5 5 5], 'inherit', '', 'square', false ) );
    switch s.type
        case 'okbutton'
            if modal
                callback = 'exitDialog(gcbo,true)';
            else
                callback = [];
            end
            s.type = 'pushbutton';
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'string', 'OK', 'fontweight', 'bold', ...
                        'callback', callback ) );
        case 'cancelbutton'
            if modal
                callback = 'exitDialog(gcbo,false)';
            else
                callback = [];
            end
            s.type = 'pushbutton';
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'string', 'Cancel', 'fontweight', 'bold', ...
                        'callback', callback ) );
        case 'hgroup'
            s.type = 'group';
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'rows', 1, 'columns', length(s.children) ) );
        case { 'group', 'vgroup' }
            s.type = 'group';
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'rows', length(s.children), 'columns', 1 ) );
    end
    if isempty( s.attribs )
        defaultSeparation = [ 0 0 ];
    else
        defaultSeparation = [ min( s.attribs.margin([1 2]) ), min( s.attribs.margin([3 4]) ) ];
    end
    switch s.type
        case ''
            % Nothing.
        case { 'pushbutton', 'togglebutton' }
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'center', 'halign', 'center', 'callback', [] ) );
            s.attribs = setDefaultTeststring( s.attribs );
        case { 'checkbox', 'radiobutton' }
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'center', 'halign', 'left', 'value', 0, 'callback', [] ) );
            s.attribs = setDefaultTeststring( s.attribs );
        case 'slider'
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'direction', 'horiz', 'callback', [], ...
                        'min', 0, 'max', 1, 'minorstep', 0.01, 'majorstep', 0.1 ) );
            if strcmp( s.attribs.direction, 'horiz' )
                s.attribs = defaultFromStruct( s.attribs, ...
                    struct( 'valign', 'center', 'halign', 'fill' ) );
            else
                s.attribs = defaultFromStruct( s.attribs, ...
                    struct( 'valign', 'fill', 'halign', 'center' ) );
            end
        case 'popupmenu'
            s.attribs = defaultFromStruct( s.attribs, struct( 'string', '' ) );
            if ~isfield( s.attribs, 'strings' )
                s.attribs.strings = splitString( '\|', s.attribs.string );
            end
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'center', 'halign', 'fill', 'callback', [], ...
                        'lines', 1 ) );
            s.attribs = setDefaultTeststring( s.attribs );
        case 'menu'
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'string', '', ...
                        'valign', 'center', 'halign', 'fill', 'callback', [], ...
                        'separator', 'off', 'lines', 1 ) );
        case 'listbox'
            MINSTRINGS = 4;
            MAXSTRINGS = 20;
            s.attribs = defaultFromStruct( s.attribs, struct( 'string', '' ) );
            if ~isfield( s.attribs, 'strings' )
                if iscell( s.attribs.string )
                    s.attribs.strings = s.attribs.string;
                else
                    s.attribs.strings = splitString( '\|', s.attribs.string );
                end
            end
            numstrings = length( s.attribs.strings );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'center', 'halign', 'fill', 'callback', [], ...
                        'multiline', false, ...
                        'lines', max( MINSTRINGS, min( numstrings, MAXSTRINGS ) ) ) );
            s.attribs = setDefaultTeststring( s.attribs );
        case 'text'
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'center', 'halign', 'left', ...
                        'haligncontent', 'left', 'lines', 1, ...
                        'string', '', ...
                        'tag', '', ...
                        'callback', [] ) );
            s.attribs = defaultFromStruct( s.attribs, struct( 'teststring', s.attribs.string ) );
        case 'edit'
            if modal
                callback = 'checkTerminationKey(gcbo)';
            else
                callback = [];
            end
            s.attribs = defaultFromStruct( s.attribs, ...
                    struct( 'string', '', 'multiline', false, 'callback', callback ) );
            if s.attribs.multiline
                s.attribs = defaultFromStruct( s.attribs, ...
                    struct( 'halign', 'fill', 'haligncontent', 'left', 'valign', 'fill', 'lines', 4 ) );
            else
                s.attribs = defaultFromStruct( s.attribs, ...
                    struct( 'halign', 'left', 'haligncontent', 'center', 'valign', 'center', 'lines', 1 ) );
            end
            s.attribs = setDefaultTeststring( s.attribs, 4 );
            teststringlen = max( length( s.attribs.string ), length( s.attribs.teststring ) );
            s.attribs.teststring = repmat( '0', 1, teststringlen );
        case 'axes'
             s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'visible', 'on' ) );
        case 'figure'
            s = setDefaultRC( s );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'equalwidths', false, 'equalheights', false, ...
                        'resize', 'off', ...
                        'tag', '', ...
                        'singlechild', false, ...
                        'selectedchild', 1, ...
                        'childpos', 'rel', ...
                        'integerhandle', 'off', ...
                        'menubar', 'none', ...
                        'handlevisibility', 'callback', ...
                        'innermargin', defaultSeparation, ...
                        'outermargin', s.attribs.margin, ...
                        'createfcn', [] ) );
            menumap = false( 1, length(s.children) );
            for i=1:length(s.children)
                menumap(i) = strcmp( s.children{i}.type, 'menu' );
            end
            s.menus = s.children(menumap);
            s.children = s.children(~menumap);
%             s.menus = { s.children{menumap} };
%             s.children = { s.children{~menumap} };
            for i=1:length(s.menus)
                s.menus{i} = fillRSSSdefaults( s.menus{i}, modal, inheritedattribs );
            end
            checkChildren( s, modal );
        case 'panel'
            s = setDefaultRC( s );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'equalwidths', false, 'equalheights', false, ...
                        'tag', '', ...
                        'bordertype', 'etchedin', ...
                        'singlechild', false, ...
                        'selectedchild', 1, ...
                        'childpos', 'rel', ...
                        'innermargin', defaultSeparation, ...
                        'outermargin', s.attribs.margin, ...
                        'callback', [] ) );
            s.attribs = setDefaultTeststring( s.attribs );
            checkChildren( s, modal );
        case 'colorchooser'
            s = setDefaultRC( s );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'tag', '', ...
                        'bordertype', 'line', ...
                        'singlechild', false, ...
                        'selectedchild', 1, ...
                        'childpos', 'rel', ...
                        'innermargin', defaultSeparation, ...
                        'outermargin', s.attribs.margin, ...
                        'callback', [] ) );
            s.attribs = setDefaultTeststring( s.attribs );
        case 'radiogroup'
            s = setDefaultRC( s );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'equalwidths', false, 'equalheights', false, ...
                        'tag', '', ...
                        'bordertype', 'etchedin', ...
                        'singlechild', false, ...
                        'selectedchild', 1, ...
                        'childpos', 'rel', ...
                        'SelectionChangeFcn', '', ...
                        'innermargin', defaultSeparation, ...
                        'outermargin', s.attribs.margin ) );
            s.attribs = setDefaultTeststring( s.attribs );
            checkChildren( s, modal );
        case 'group'
            s.type = 'group';
            s = setDefaultRC( s );
            s.attribs = defaultFromStruct( s.attribs, ...
                struct( 'valign', 'fill', 'halign', 'fill', ...
                        'equalwidths', false, 'equalheights', false, ...
                        'tag', '', ...
                        'singlechild', false, ...
                        'selectedchild', 1, ...
                        'innermargin', defaultSeparation, ...
                        'outermargin', [0 0 0 0] ) );
            checkChildren( s, modal );
    end
    MINSIZE = [10 10];
    s.attribs = defaultFromStruct( s.attribs, ...
        struct( 'name', '', ...
                'string', '', ...
                'visible', 'on', ...
                'fontweight', 'normal', ...
                'fontsize', 0, ...
                'position', [ 0 0 MINSIZE ], ...
                'minsize', MINSIZE, ...
                'childpos', 'abs', ...
                'halign', 'center', ...
                'valign', 'center', ...
                'innerhalign', 'fill', ...
                'innervalign', 'fill', ...
                'margin', [ 0 0 0 0 ], ...
                'inherit', '' ) );
    inheritedfields = splitString( '|', s.attribs.inherit );
    for i=1:length(inheritedfields)
        fn = inheritedfields{i};
        if isfield( s.attribs, fn )
            inheritedattribs.(fn) = s.attribs.(fn);
        end
    end
    s.attribs = rmfield( s.attribs, 'margin' );
    s.attribs.tag = autotag( s );
    if isfield( s.attribs, 'singlechild' ) && s.attribs.singlechild
        s.attribs.rows = 1;
        s.attribs.columns = 1;
    end
    for i=1:length(s.children)
        s.children{i} = fillRSSSdefaults( s.children{i}, modal, inheritedattribs );
    end
end

function s = setDefaultRC( s )
    if isfield( s.attribs, 'rows' )
        if isfield( s.attribs, 'columns' )
            % Make sure there are enough rows.
            s.attribs.rows = max( s.attribs.rows, ceil( length(s.children)/s.attribs.columns ) );
        else
            s.attribs.rows = max( s.attribs.rows, 1 );
            s.attribs.columns = ceil( length(s.children)/s.attribs.rows );
        end
    else
        if isfield( s.attribs, 'columns' )
            s.attribs.columns = max( s.attribs.columns, 1 );
        else
            s.attribs.columns = 1;
        end
        s.attribs.rows = ceil( length(s.children)/s.attribs.columns );
    end
end

function checkChildren( s, modal )
    diff = s.attribs.rows * s.attribs.columns - length(s.children);
    if diff > 0
        empty = struct( 'type', 'group' );
        empty = fillRSSSdefaults( empty, modal );
        for i=1:diff
            s.children{diff+i} = empty;
        end
    elseif diff < 0
        fprintf( 1, '%s: %d rows * %d cols = %d expected children, %d found.\n', ...
            mfilename, ...
            s.attribs.rows, s.attribs.columns, ...
            s.attribs.rows * s.attribs.columns, ...
            length(s.children) );
        s.children = {s.children{1:(s.attribs.rows * s.attribs.columns)}};
    end
end

function [r,c] = defaultRC( n )
    r = 0;
    c = 0;
    s = floor(sqrt(n));
    for i=s:-1:1
        if mod(n,i)==0
            r = i;
            c = n/i;
            return;
        end
    end
end

function a = setDefaultTeststring( a, minlen )
    if ~isfield( a, 'teststring' )
        if isfield( a, 'strings' ) && ~isempty(a.strings)
            s = a.strings{1};
        elseif isfield( a, 'string' )
            s = a.string;
        else s = '';
        end
        if (nargin >= 2) && (length( s ) < minlen)
            s = repmat( '0', 1, minlen );
        end
        a = defaultFromStruct( a, struct( 'teststring', s ) );
    end
end

function tag = autotag( s )
    tag = '';
    if isfield( s.attribs, 'tag' )
        tag = s.attribs.tag;
        return;
    end
    if isfield( s.attribs, 'name' ) && ~isempty( s.attribs.name )
        tag = s.attribs.name;
    elseif isfield( s.attribs, 'strings' ) && ~isempty( s.attribs.strings )
        for i=1:length(s.attribs.strings)
            if ~isempty( s.attribs.strings{i} )
                tag = s.attribs.strings{i};
                break;
            end
        end
    elseif isfield( s.attribs, 'string' ) && ~isempty( s.attribs.string )
        tag = s.attribs.string;
    end
    if isempty(tag)
        return;
    end
    tag = lower(  [ s.type '_' tag ] );
    tag = normaliseTag( tag );
end
