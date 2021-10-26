function s = buildRSSSdialogFromFile( fn, modal, initvals, userdata, initfun )
%s = buildRSSSdialogFromFile( fn, modal, initvals, userdata, initfun )
%   Create a dialog from the dialogspec contained in the file called fn.
%   Fill it with values from initvals (a struct mapping item tags to
%   values).
%   s is a structure describing the dialog.
%
%   See also:
%       getRSSSFromFile, performRSSSdialogFromFile, modelessRSSSdialogFromFile

    if nargin < 3
        initvals = [];
    end
    s = getRSSSFromFile( fn, initvals );
    if isempty(s)
        return;
    end
    if ~strcmp( s.type, 'figure' )
        s1 = struct( 'type', 'figure', 'attribs', struct() );
        s1.children = { s };
        s = s1;
    end
    if (nargin >= 3) && ~isempty( initvals )
        s = insertInitVals( s, initvals );
    end
    s = fillRSSSdefaults( s, modal );
    ipos = [0 0 1 1];
    [s,links] = buildRSSSstructdialog( s, [], ipos );
    s = getRSSSPositions( s );
    s = compactRSSSSpace( s );
    ipos = [ 0 0 max( s.attribs.minsize, [128 1] ) ];
    s = forceRSSSPosition( s, ipos );
    setRSSSPositions( s );
    changeFigSize( s.handle, s.attribs.minsize );
    s = setRSSSColors( s );
    centreDialog(s.handle);
    if (nargin >= 3) && ~isempty( userdata )
      % set( s.handle, 'UserData', userdata );
        s = defaultFromStruct( s, userdata );
    end
    set( s.handle, 'UserData', s, 'Visible', 'off', ...
                   'ResizeFcn', @rsssResize );
    if (nargin >= 4) && ~isempty( initfun )
        initfun( s.handle );
    end
    if isfield( s.attribs, 'precallback' ) ...
            && ~isempty( s.attribs.precallback )
        fh = str2func( s.attribs.precallback );
        fh( s.handle );
    end
    % setGUIColors( s.handle, [0.4 0.8 0.4], [0.9 1 0.9] );
    set( s.handle, 'Visible', 'on' );
    if isfield( s.attribs, 'focus' )
      % fprintf( 1, 'Have s.attribs.focus = %s\n', s.attribs.focus );
        focus = s.attribs.focus;
        h = guidata( s.handle );
        if isfield( h, focus )
          % fprintf( 1, 'Setting focus to %s %f\n', focus, h.(focus) );
            uicontrol( h.(focus) );
        end
    end
    
    % Connect sliders and text boxes.
    if ~isempty(links)
        hh = guidata( s.handle );
        for i=1:size(links,1)
            if isfield( hh, links{i,1} ) && isfield( hh, links{i,2} )
                text = hh.(links{i,1});
                slider = hh.(links{i,2});
                cb = get(text,'callback');
                if isempty(cb)
                    cb = get(slider,'callback');
                end
                connectTextAndSlider( text, slider, '', cb, true );
            end
        end
    end
end

function rsssResize( hObject, eventdata )
    pos = get( hObject, 'Position' );
    s = get( hObject, 'UserData' );
    s = forceRSSSPosition( s, pos );
    for i=1:length(s.children)
        setRSSSPositions( s.children{i} );
    end
    set( hObject, 'UserData', s );
end

function s = insertInitVals( s, initvals )
    if isfield( s.attribs, 'tag' )
        tag = s.attribs.tag;
        if isfield( initvals, tag )
            switch s.type
                case { 'figure', 'text', 'edit' }
                    s.attribs.string = initvals.(tag);
                case { 'checkbox', 'togglebutton', 'pushbutton', 'radiobutton' }
                    if isnumeric( initvals.(tag) ) || islogical( initvals.(tag) )
                        s.attribs.value = initvals.(tag);
                    else
                        [x,n,errmsg] = sscanf( initvals.(tag), '%d' );
                        if (n ~= 1) || isempty(x)
                            x = 0;
                        end
                        s.attribs.value = x;
                    end
            end
        end
    end
    for i=1:length(s.children)
        s.children{i} = insertInitVals( s.children{i}, initvals );
    end
end

function setRSSSvalues( s, initvals )
    handles = guidata( s.handle );
    fns = fieldnames( initvals );
    for i=1:length(fns)
        fn = fns{i};
        if isfield( handles, fn )
            setGUIvalue( handles.(fn), initvals.(fn) );
        end
    end
end

function setGUIvalue( guih, val )
    type = get( guih, 'Type' );
    switch type
        case 'uicontrol'
            switch get( guih, 'Style' )
                case { 'togglebutton', 'radiobutton', 'checkbox' }
                    set( guih, 'Value', val );
                case { 'text', 'edit' }
                    set( guih, 'String', val );
            end
        case 'figure'
            set( guih, 'Name', val );
    end
end

function changeFigSize( h, sz )
    pos = get( h, 'Position' );
    newpos = [ pos(1), pos(2)+pos(4)-sz(2), sz ];
    set( h, 'Position', newpos );
end
