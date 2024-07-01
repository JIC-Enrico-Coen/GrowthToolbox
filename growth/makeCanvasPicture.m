function theaxes = makeCanvasPicture( msg, varargin )
%fig = makeCanvasPicture( msg, varargin )
%   Create a figure window containing a canvas picture, legend, report
%   text, colorbar, etc.
%
%   Options:
%   'figure':   An existing figure can be supplied, instead of creating a
%               new one.
%   'fpos':     The position of the figure on the screen, given as a
%               four-element array of integers [x y width height].  If a
%               two-element array is given, it will be interpreted as
%               [width height], and the figure will be automatically
%               centered on the screen.
%   'ppos':     The relative position of the picture content elements
%               within the figure.  This is also a four-element array. The
%               picture elements will be automatically laid out within this
%               rectangle.  If ppos is supplied, fpos is omitted, and a new
%               figure is being created, then the new figure will be
%               automatically sized to fit the contents.
%   'black'     A boolean, by default false.  If true, the picture will
%               have a black background, otherwise white.
%   'add'       A boolean, by default true.  If false, any existing picture
%               will be deleted, otherwise it will be retained.
%   'stereooffset'  A real number, by default zero.  The number of degrees
%               of azimuth by which the view will be changed relative to
%               that indicated by the scrollbar.
%   'properties'   A structure containing any other attribute of the
%               figure that should be set.
%   'uicontrols'   If true, sliderbars and text items will be created,
%               otherwise not.
%   'Visible'   If 'on' or true, the figure will be made vsible, if any
%               other value then invisible, if not given then no change is
%               made to visibility
%
%   The UserData of the figure will be set to a structure containing
%   handles to all of the created components, and the Position attribute of
%   the figure.  The latter is needed because when the figure is resized,
%   this is the only way the resize function has of knowing what the old
%   size was.
%
%   This procedure is also used by the resize callback (ResizeFcn).
%   If a figure is given to it which already has a nonempty UserData
%   component, then the UserData is assumed to be a structure as above, and
%   the components are resized and repositioned as required, instead of
%   being created.  If the figure is found not to have actually changed its
%   size, the resize function does nothing.

    if isempty(msg)
        msg = mfilename();
    end
    [s,ok] = safemakestruct( msg, varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'figure', -1, ...
        'fpos', [], ...
        'ppos', [], ...
        'black', false, ...
        'add', true, ...
        'stereooffset', 0, ...
        'properties', [], ...
        'uicontrols', true );

    % Unexpected arguments are warned about and ignored.
    checkcommandargs( msg, s, 'only', ...
        'figure', 'fpos', 'ppos', 'black', 'add', 'stereooffset', 'properties', 'uicontrols' );

    if ~checkvalidpos( s.fpos )
        return;
    end
    if ~checkvalidpos( s.ppos )
        return;
    end
    
%     timedFprintf( 1, 'Argument struct:\n' );
%     s

    s = calcPositions( s );

    % The required figure window now exists, and s.figure is a handle to it.
    % s.fpos is its position and size, and s.ppos is the position and size
    % of the bounding rectangle of the picture elements.
    
    set( s.figure, 'Units', 'pixels' );
    if ~isempty(s.properties)
        set( s.figure, s.properties );
    end
    h = guidata( s.figure );
    
    % Calculate the placement of all the picture elements:
    %   pictureBackground
    %   legend
    %   picture
    %   azimuth scroll bar
    %   elevation scrollbar
    %   roll scrollbar
    %   report text
    %   colorbar
    %   text items for the ends of the colorbar
    %   scale bar
    
    haveAzimuth = s.uicontrols && haveItem( h, 'azimuth' );
    haveElevation = s.uicontrols && haveItem( h, 'elevation' );
    haveRoll = s.uicontrols && haveItem( h, 'roll' );
    haveLegend = s.uicontrols && haveItem( h, 'legend' );
    haveReport = s.uicontrols && haveItem( h, 'report' );
    haveColorbar = s.uicontrols && haveItem( h, 'colorbar' );
    
%     haveAzimuth = s.uicontrols && (isempty(h) || ishandle(h.azimuth));
%     haveElevation = s.uicontrols && (isempty(h) || ishandle(h.elevation));
%     haveRoll = s.uicontrols && (isempty(h) || ishandle(h.roll));
%     haveLegend = s.uicontrols && (isempty(h) || ishandle(h.legend));
%     haveReport = s.uicontrols && (isempty(h) || ishandle(h.report));
%     haveColorbar = s.uicontrols && (isempty(h) || ishandle(h.colorbar));

% These are not used.
%     haveColortexthi = s.uicontrols && (isempty(h) || ishandle(h.colortexthi));
%     haveColornamehi = s.uicontrols && (isempty(h) || ishandle(h.colornamehi));
%     haveColortextlo = s.uicontrols && (isempty(h) || ishandle(h.colortextlo));
%     haveColornamelo = s.uicontrols && (isempty(h) || ishandle(h.colornamelo));
%     haveScalebar = s.uicontrols && (isempty(h) || ishandle(h.scalebar));

    %     h.figure = s.figure;

    panelinset = 0;
    fontscale = 1.7;
    if haveAzimuth || haveElevation || haveRoll
        scrollbarthickness = 15;
    else
        scrollbarthickness = 0;
    end
    colorbartextwidth = 40;
%    if haveColortexthi || haveColortextlo
        colortextfontsize = 8;
        colorbartextheight = ceil(colortextfontsize*fontscale)+1;
%    else
%        colorbartextheight = 0;
%    end
    azimuthfontsize = 8;
    elevationfontsize = 8;
    rollfontsize = 8;
    if haveColorbar
        colorbarwidth = 15;
    else
        colorbarwidth = 0;
    end
    backgroundinset = 2;

    if haveReport
        reportfontsize = 10;
        reportlineheight = ceil(reportfontsize*fontscale)+1;
        reportlines = 3;

        reportheight = reportlineheight*reportlines;
    else
        reportheight = 0;
    end

    
    picpanelheight = s.ppos(4) - scrollbarthickness - reportheight;
    picpanelwidth = s.ppos(3) - scrollbarthickness - colorbarwidth - colorbartextwidth;
    picpanelpos = rectInRect( s.ppos, 'nw', [0 0 picpanelwidth picpanelheight] );
    
    if haveLegend
        legendfontsize = 28;
        legendlineheight = ceil(legendfontsize*fontscale)+1;
        legendinset = 5;
        legendwidth = picpanelwidth - legendinset*2;
        legendlines = 2;
        legendheight = legendlineheight*legendlines;
    else
        legendinset = 0;
        legendwidth = 0;
        legendheight = 0;
    end
    scalebarinset = 0;
    scalebarwidth = 100;
    scalebarheight = 12;
    scalebarfontsize = 10;

    picbkgndpos = [ panelinset, panelinset, ...
                    picpanelpos(3)-panelinset*2, picpanelpos(4)-panelinset*2 ];
    picpos = insetRect( picbkgndpos, backgroundinset );
    picpos = makeSquare( picpos );
    legendpos = rectInRect( picpanelpos, 'nw', ...
        [legendinset legendinset legendwidth legendheight] );
    scalebarpos = rectInRect( picbkgndpos, 'sw', ...
        [scalebarinset scalebarinset scalebarwidth scalebarheight] );
    azimuthpos = abutRect( picpanelpos, 's', 0, scrollbarthickness );
    reportpos = abutRect( azimuthpos, 's', 0, reportheight );
    elevationpos = abutRect( picpanelpos, 'e', 1, scrollbarthickness );
    rollpos = abutRect( elevationpos, 'e', 1, scrollbarthickness );
    resetviewpos = abutRect( elevationpos, 's', 1, scrollbarthickness );
    rollzeropos = abutRect( rollpos, 's', 1, scrollbarthickness );
    colorbarpos = abutRect( rollpos, 'e', -1, colorbarwidth );
    colortexthipos = abutRect( colorbarpos, 'en', 2, colorbartextwidth, colorbartextheight );
    colortextlopos = abutRect( colorbarpos, 'es', 2, colorbartextwidth, colorbartextheight );
    colornamehipos = abutRect( colortexthipos, 'sw', 2, colorbartextheight, colorbartextwidth );
    colornamelopos = abutRect( colortextlopos, 'nw', 2, colorbartextwidth, colorbartextheight );
    colortitlepos = abutRect( colornamehipos, 'sw', 2, colorbartextheight, colorbartextwidth );
    azimuthtextpos = abutRect( colortitlepos, 'sw', 2, colorbartextheight, colorbartextwidth );
    elevationtextpos = abutRect( azimuthtextpos, 'sw', 2, colorbartextheight, colorbartextwidth );
    rolltextpos = abutRect( elevationtextpos, 'sw', 2, colorbartextheight, colorbartextwidth );
    
    if isempty(h)
        % This is a new figure.  Create all the components.
        h.stereooffset = s.stereooffset;
        h.siblings = [];
        h.figurepos = get( s.figure, 'Position' );
        h.GFTwindow = s.figure;
        
        if s.black
            backgroundColor = [0 0 0];
        else
            backgroundColor = [1 1 1];
        end
        figureColor = get(s.figure, 'Color');
    
        h.picturepanel = uipanel( s.figure, ...
            'Tag', 'picturepanel', ...
            'Units', 'pixels', ...
            'Position', picpanelpos, ...
            'BackgroundColor', backgroundColor, ...
            'ForegroundColor', backgroundColor, ...
            'HighlightColor', backgroundColor, ...
            'ShadowColor', backgroundColor );
        h.resetViewControl = uipanel( s.figure, ...
            'Tag', 'resetViewControl', ...
            'Units', 'pixels', ...
            'Position', resetviewpos, ...
            'BackgroundColor', [1 1 1], ...
            'ForegroundColor', backgroundColor, ...
            'HighlightColor', backgroundColor, ...
            'ShadowColor', backgroundColor, ...
            'ButtonDownFcn', @rstvw_Callback );
        h.rollzeroControl = uipanel( s.figure, ...
            'Tag', 'rollzeroControl', ...
            'Units', 'pixels', ...
            'Position', rollzeropos, ...
            'BackgroundColor', [1 1 1], ...
            'ForegroundColor', backgroundColor, ...
            'HighlightColor', backgroundColor, ...
            'ShadowColor', backgroundColor, ...
            'ButtonDownFcn', @rollz_Callback );

        h.pictureBackground = axesInPixels( h.GFTwindow, picbkgndpos, ...
          'Visible', 'on', ...
          'Units', 'pixels', ...
          'Parent', h.picturepanel, ...
          'Tag', 'pictureBackground', ...
          'HitTest', 'off' );
        % 'CameraViewAngleMode', 'manual' ); % Don't do this -- it screws up
        %    getframe().
        hold( h.pictureBackground, 'on' );
      % emptyAxesColor( h.pictureBackground, [1 0 0] );
        view( h.pictureBackground, [0 90] );
        axis( h.pictureBackground,'off' );
        hold( h.pictureBackground,'off' );
        set( h.pictureBackground, ...
            'XLim', [-0.5 0.5], ...
            'XLimMode', 'manual', ...
            'YLim', [-0.5 0.5], ...
            'YLimMode', 'manual', ...
            'ZLim', [-0.5 0.5], ...
            'ZLimMode', 'manual' );

        h.picture = axesInPixels( h.GFTwindow, picpos, ...
              'Visible', 'on', ...
              'Units', 'pixels', ...
              'Parent', h.picturepanel, ...
              'Tag', 'picture' );
        hold( h.picture, 'on' );
        forceColor( h.picture, [1 1 1] );
        setaxis( h.picture, [-1 1 -1 1 -1 1] );
        setview( h.picture, -45 + h.stereooffset, 33.75 );
        axis( h.picture, 'square' );
        hold( h.picture, 'off' );

        if haveColorbar
            a = axesInPixels( h.GFTwindow, colorbarpos, ...
                          'Visible', 'on', ...
                          'Units', 'pixels', ...
                          'Parent', s.figure, ...
                          'Tag', 'colorbar' );
            h.colorbar = a;
            hold( h.colorbar, 'on' );
            forceColor( h.colorbar, [0.5 0.5 0.5] );
            fillAxes( h.colorbar, [0.5 0.5 0.5] )
            axis( h.colorbar, [0 1 0 1] );
            axis( h.colorbar, 'off' );
            hold( h.colorbar, 'off' );
        else
            h.colorbar = -1;
        end

        if s.uicontrols
            h.azimuth = uicontrol( s.figure, ...
                'Tag', 'azimuth', ...
                'Units', 'pixels', ...
                'Style', 'slider', ...
                'Position', azimuthpos, ...
                'Max', 180, ...
                'Min', -180, ...
                'SliderStep', [1/160 1/32], ...
                'Value', 45, ...
                'Callback', @view_Callback );
            h.elevation = uicontrol( s.figure, ...
                'Tag', 'elevation', ...
                'Units', 'pixels', ...
                'Style', 'slider', ...
                'Position', elevationpos, ...
                'Max', 90, ...
                'Min', -90, ...
                'SliderStep', [1/80 1/16], ...
                'Value', -33.75, ...
                'Callback', @view_Callback );
            h.roll = uicontrol( s.figure, ...
                'Tag', 'roll', ...
                'Units', 'pixels', ...
                'Style', 'slider', ...
                'Position', rollpos, ...
                'Max', 180, ...
                'Min', -180, ...
                'SliderStep', [1/80 1/16], ...
                'Value', 0, ...
                'Callback', @view_Callback );
            h.legend = uicontrol( s.figure, ...
                'Tag', 'legend', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', legendpos, ...
                'FontSize', legendfontsize, ...
                'FontWeight', 'bold', ...
                'FontUnit', 'points', ...
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', backgroundColor, ...
                'ForegroundColor', 1 - backgroundColor, ...
                'String', {}, ...
                'Visible', 'off' );
            h.report = uicontrol( s.figure, ...
                'Tag', 'report', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', reportpos, ...
                'FontSize', reportfontsize, ...
                'HorizontalAlignment', 'left', ...
                'FontWeight', 'bold', ...
                'FontUnit', 'points', ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', {} );
            h.colortexthi = uicontrol( s.figure, ...
                'Tag', 'colortexthi', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', colortexthipos, ...
                'FontSize', colortextfontsize, ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', '10.000' );
            h.colornamehi = uicontrol( s.figure, ...
                'Tag', 'colornamehi', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', colornamehipos, ...
                'FontSize', colortextfontsize, ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', 'TEXTHI' );
            h.colortitle = uicontrol( s.figure, ...
                'Tag', 'colortitle', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', colortitlepos, ...
                'FontSize', colortextfontsize, ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', '' );
            h.colortextlo = uicontrol( s.figure, ...
                'Tag', 'colortextlo', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', colortextlopos, ...
                'FontSize', colortextfontsize, ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', '-10.000' );
            h.colornamelo = uicontrol( s.figure, ...
                'Tag', 'colornamelo', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', colornamelopos, ...
                'FontSize', colortextfontsize, ...
                'BackgroundColor', figureColor, ...
                'ForegroundColor', [0 0 0], ...
                'String', 'TEXTLO' );
            h.scalebar = uicontrol( s.figure, ...
                'Parent', h.picturepanel, ...
                'Tag', 'scalebar', ...
                'Units', 'pixels', ...
                'Style', 'text', ...
                'Position', scalebarpos, ...
                'FontSize', scalebarfontsize, ...
                'FontWeight', 'bold', ...
                'FontUnit', 'points', ...
                'HorizontalAlignment', 'center', ...
                'BackgroundColor', 1 - backgroundColor, ...
                'ForegroundColor', backgroundColor, ...
                'String', {} );
            if true
                h.azimuthtext = uicontrol( s.figure, ...
                    'Tag', 'azimuthtext', ...
                    'Units', 'pixels', ...
                    'Style', 'text', ...
                    'Position', azimuthtextpos, ...
                    'FontSize', azimuthfontsize, ...
                    'BackgroundColor', figureColor, ...
                    'ForegroundColor', [0 0 0], ...
                    'String', 'az:' );
                h.elevationtext = uicontrol( s.figure, ...
                    'Tag', 'elevationtext', ...
                    'Units', 'pixels', ...
                    'Style', 'text', ...
                    'Position', elevationtextpos, ...
                    'FontSize', elevationfontsize, ...
                    'BackgroundColor', figureColor, ...
                    'ForegroundColor', [0 0 0], ...
                    'String', 'el:' );
                h.rolltext = uicontrol( s.figure, ...
                    'Tag', 'rolltext', ...
                    'Units', 'pixels', ...
                    'Style', 'text', ...
                    'Position', rolltextpos, ...
                    'FontSize', rollfontsize, ...
                    'BackgroundColor', figureColor, ...
                    'ForegroundColor', [0 0 0], ...
                    'String', 'el:' );
            end
        else
            h.azimuth = -1;
            h.elevation = -1;
            h.legend = -1;
            h.scalebar = -1;
            h.report = -1;
            h.colortexthi = -1;
            h.colortextlo = -1;
            h.colornamehi = -1;
            h.colornamelo = -1;
            h.azimuthtext = -1;
            h.elevationtext = -1;
            h.rolltext = -1;
        end
        set( s.figure, 'ResizeFcn', @resizePicWindow );
    else
        % This is an existing figure in which all of the necessary
        % components already exist.  Resize and reposition them as
        % required.
        h.figurepos = get( s.figure, 'Position' );
        set( h.picturepanel, 'Position', picpanelpos );
        set( h.pictureBackground, 'Position', picbkgndpos );
        set( h.picture, 'Position', picpos );
        tryset( h.colorbar, 'Position', colorbarpos );
        if s.uicontrols
            tryset( h.azimuth, 'Position', azimuthpos );
            tryset( h.elevation, 'Position', elevationpos );
            tryset( h.roll, 'Position', rollpos );
            tryset( h.azimuthtext, 'Position', azimuthtextpos );
            tryset( h.elevationtext, 'Position', elevationtextpos );
            tryset( h.rolltext, 'Position', rolltextpos );
            tryset( h.legend, 'Position', legendpos );
            tryset( h.report, 'Position', reportpos );
            tryset( h.colortexthi, 'Position', colortexthipos );
            tryset( h.colortextlo, 'Position', colortextlopos );
            tryset( h.colornamehi, 'Position', colornamehipos );
            tryset( h.colornamelo, 'Position', colornamelopos );
            tryset( h.colortitle, 'Position', colortitlepos );
        end
    end

    guidata( s.figure, h );
    theaxes = h.picture;
end

function a = axesInPixels( fig, rect, varargin )
    fpos = get( fig, 'Position' );
    a = axes( 'Position', ... 
          [ rect(1)/fpos(3), ...
            rect(2)/fpos(4), ...
            rect(3)/fpos(3), ...
            rect(4)/fpos(4) ], ...
          varargin{:} );
    if any( get(a,'Position') ~= rect )
      % fprintf( 1, 'axesInPixels misplaced: said [%.2f %.2f %.2f %.2f], got [%.2f %.2f %.2f %.2f]\n', ...
      %     rect, get(gca,'Position') );
        set( a, 'Position', rect );
    end
end

function forceColor( h, c )
%forceColor( h, c )
%   Set every possible color attribute of h to c.  Do not crash.

    tryset( h, 'ForegroundColor', c );
    tryset( h, 'BackgroundColor', c );
    tryset( h, 'Color', c );
end

function s = calcPositions( s )
    posinfocode = length(s.fpos)*10 + length(s.ppos);
    pic_insetx = 0;
    pic_insety = 0;
    extrawidth = pic_insetx*2;
    extraheight = pic_insety*2;
    
    if posinfocode==00
        if ishandle(s.figure)
            fig = s.figure;
        elseif isinteger(s.figure) && (s.figure > 0)
            fig = figure(s.figure);
        else
            s.figure = figure( 'Units', 'pixels' );
            fig = s.figure;
        end
        if ~isempty( s.properties )
            set( fig, s.properties );
        end
        s.fpos = get( fig, 'Position' );
        s.ppos = [ pic_insetx, pic_insety, ...
                   s.fpos(3) - extrawidth, s.fpos(4) - extraheight ];
    elseif posinfocode==20
        s.ppos = s.fpos - [ extrawidth, extraheight ];
        s = calcPositions(s);
    elseif posinfocode==02
        s.fpos = s.ppos + [ extrawidth, extraheight ];
        s = calcPositions(s);
    elseif posinfocode==22
        if ishandle( s.figure )
            figpos = get( s.figure, 'Position' );
            s.fpos = [ figpos([1 2]) s.fpos ];
        else
            globpos = get( 0, 'ScreenSize' );
            s.fpos = [ round((globpos([3 4]) - s.fpos)/2), s.fpos ];
        end
        s = calcPositions(s);
    elseif posinfocode==40
        s.ppos = [ pic_insetx, pic_insety, ...
                   s.fpos(3) - extrawidth, s.fpos(4) - extraheight ];
        s = calcPositions(s);
    elseif posinfocode==42
        s.ppos = [ pic_insetx, pic_insety, s.ppos ];
        s = calcPositions(s);
    elseif posinfocode==04
        s.fpos = s.ppos([3 4]) + s.ppos([1 2]) + [ extrawidth, extraheight ];
        s = calcPositions(s);
    elseif posinfocode==24
        if ishandle( s.figure )
            figpos = get( s.figure, 'Position' );
            s.fpos = [ figpos([1 2]) s.fpos ];
        else
            globpos = get( 0, 'Position' );
            s.fpos = [ round((globpos([1 2]) - s.fpos([3 4]))/2), s.fpos ];
        end
        s = calcPositions(s);
    elseif posinfocode==44
        if s.ppos(3)==0  % Means make as wide as possible.
            s.ppos(3) = s.fpos(3) - s.ppos(1) - extrawidth;
        end
        if s.ppos(4)==0  % Means make as tall as possible.
            s.ppos(4) = s.fpos(4) - s.ppos(2) - extraheight;
        end
        if ishandle( s.figure )
            set( s.figure, 'Position', s.fpos );
            figure( s.figure );
        elseif s.figure > 0
            s.figure = figure( s.figure );
            set( s.figure, 'Position', s.fpos, 'Units', 'pixels' );
        else
            s.figure = figure( 'Position', s.fpos, 'Units', 'pixels' );
        end
    else
        % Ignore.
    end
    
    if isfield( s, 'Visible' )
        s.figure.Visible = s.Visible;
    end
end

function ok = checkvalidpos( pos )
    ok = any(length(pos) == [0 2 4]);
    if ~ok
        fprintf( 1, '%s: position should have 2 or 4 elements, %d found.\n', ...
            msg, length(pos) );
    end
end

function fillAxes( a, color )
%fillAxes( a, color )
%   Fill the axes with the given colour, by drawing a rectangle of size
%   equal to the bounds.
%   oldaxes = gca;
%   axes(a);
    bounds = axis(a);
    fill( bounds([1 2 2 1]), ...
          bounds([3 3 4 4]), ...
          color, 'Parent', a );
%   axes(oldaxes);
end

function resizePicWindow( fig, varargin )
    if ~ishghandle( fig )
        return;
    end
    fpos = get( fig, 'Position' );
    if ~isempty( fpos )
        return;
    end
    h = guidata( fig );
    ppos = get( h.picturepanel, 'Position' );
    ppos([2 3 4]) = 0;
  % fprintf( 1, 'resizePicWindow [%.2f %.2f] [%.2f %.2f]\n', h.figurepos([3 4]), fpos([3 4]) );
    if any( h.figurepos([3 4]) ~= fpos([3 4]) )
        makeCanvasPicture( '', 'figure', fig, ...
            'fpos', fpos, 'ppos', ppos );
    end
end

function view_Callback( hObject, varargin )
    h = guidata( hObject );
    [oldaz,oldel,oldroll] = getview(h.picture);
    newaz = -get( h.azimuth, 'Value' );
    newel = -get( h.elevation, 'Value' );
    newroll = -get( h.roll, 'Value' );
    if (oldaz ~= newaz) || (oldel ~= newel) || (oldroll ~= newroll)
        setMultiView( h.siblings, newaz, newel, newroll );
        drawnow;
    end
end

function rstvw_Callback( hObject, varargin )
    h = guidata( hObject );
    set( h.azimuth, 'Value', 45 );
    set( h.elevation, 'Value', -33.75 );
    set( h.roll, 'Value', 0 );
    view_Callback( hObject, varargin )
end

function rollz_Callback( hObject, varargin )
    h = guidata( hObject );
    set( h.roll, 'Value', 0 );
    view_Callback( hObject, varargin )
end

function have = haveItem( h, item )
    have = isempty(h) || (isfield( h, item ) && ishandle(h.(item)));
end
