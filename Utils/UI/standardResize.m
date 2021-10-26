function standardResize(hObject, handles)
%standardResize(hObject, handles)
% hObject    handle to GFTwindow (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
%   This is a figure resize callback routine.  It assumes that the figure
%   consists of two parts: a control panel of fixed size, and a picture
%   which is to be automatically resized to take up maximum space in the
%   window.  The picture has horizontal and vertical scroll bars, and a
%   text area below the latter: all of these are to be moved and resized
%   along with the picture.
%
%   Handles is assumed to have the following fields:
%       initmainpanelposition:
%           A 4-element array containing the initial position and size of
%           the control panel.
%       margin:
%           The distance between the control panel and the top and left
%           edges of the window.
%       picturepanel
%           Handle to the panel containing the picture.
%       picture, legend, elevation, roll, azimuth, report:
%           Handles for the picture, the vertical scroll bars, the
%           horizontal scroll bar, and the text area respectively.

% The 'Position' attribute of any GUI element is a 4-element array:
%   [x y w h], where (x,y) is the position of its lower left corner
%   relative to its parent's lower left corner.  x = horizontal, y =
%   vertical.  w = width, h = height.  All measurements in pixels.

% Put the main control panel in the correct position.  Its top left corner
% should not move when the window is resized, so its y component (which is
% relative to the window's bottom edge) must be adjusted.

    % margin = handles.interfacestate.margin;
    margin = 1;
    windowposition = get( hObject, 'Position' );
    mainpanelposition = handles.interfacestate.initmainpanelposition;
    l = mainpanelposition(1);
    b = windowposition(4) ...
            - margin ...
            - mainpanelposition(4);
    w = mainpanelposition(3);
    h = mainpanelposition(4);
    mainpanelposition = [ l, b, w, h ];
    set( handles.mainpanel, 'Position', mainpanelposition );

% The picture panel should be sized so that:
% * Its top edge is just below the top of the window.
% * It is just large enough to enclose the picture, the scroll bars, the
%   colorbar, and the report.
% * The picture is square.
% * The picture is as large as possible subject to the above.
    reportposition = tryget( handles.report, 'Position' );
    vscrollwidth = 15; % vscrollposition(3);
    hscrollheight = 15; % hscrollposition(4);
    reportheight = reportposition(4);
    colorbarwidth = 15; % colorbarposition(3);
    colorbartextgap = 2;
    fontscale = 1.7;
    colortextfontsize = 8;
    colorbartextwidth = colortextfontsize*8;
    colorbartextheight = ceil(colortextfontsize*fontscale)+1;
    rightmargin = 0; % 2;
    
    arena = [ l+w, 0, windowposition(3)-l-w, windowposition(4) ];
    maxpicpanelwidth = arena(3) ...
                       - vscrollwidth ...
                       - vscrollwidth ...
                       - colorbarwidth ...
                       - colorbartextgap ...
                       - colorbartextwidth ...
                       - rightmargin;
    maxpicpanelheight = arena(4) - hscrollheight - reportheight;
    minpicsize = 20;
    picpanelsize = max(min(maxpicpanelwidth,maxpicpanelheight),minpicsize);
    
    picpanelposition = [ arena(1), arena(2) + arena(4) - picpanelsize, ...
                         picpanelsize, picpanelsize ];
    widepicpanelposition = picpanelposition;
    widepicpanelposition(3) = widepicpanelposition(3) + colorbarwidth;
    set( handles.picturepanel, 'Position', picpanelposition );

    % Place the picture within the panel.
    insetControl( handles.picturepanel, handles.picture, margin );

    % Place the colorbar just to the right of the picture panel.
    colorbarPos = abutRight( picpanelposition, colorbarwidth );
    set( handles.colorbar, 'Position', colorbarPos );

    % Place the picture background to exactly cover the picture and colorbar.
    pbRect = get( handles.picture, 'Position' );
    pbRect(3) = pbRect(3)+colorbarPos(3);
    set( handles.pictureBackground, 'Position', pbRect );
    scalebarpos = get( handles.scalebar, 'Position' );
    scalebarpos = rectInRect( pbRect, 'sw', [1 0 scalebarpos([3 4])] );
%     descriptionpos = [ scalebarpos(1) + scalebarpos(3), scalebarpos(2), ...
%                        pbRect(3) - scalebarpos(3) - scalebarpos(1), scalebarpos(4) ];
    set( handles.scalebar, 'Position', scalebarpos );
    setscalebarsize( handles );

    % Place the legend along the top of the picture.
    lRectHeight = ceil(get( handles.legend, 'FontSize' )*3.5);
    lRect = placeRectInRect( get( handles.picture, 'Position' ), ...
                             [0 0 0 lRectHeight], [6 6 6 6], 'nwe' );
    set( handles.legend, 'Position', lRect );

    % Place the horizontal scroll bar just underneath the picture panel.
    azimuthPos = abutBelow( widepicpanelposition, hscrollheight );
    set( handles.azimuth, 'Position', azimuthPos + [ 0 -1 0 0 ] );
    
    % Place the report just underneath the horizontal scroll bar.
    reportPos = abutBelow( azimuthPos, reportheight );
    set( handles.report, 'Position', reportPos );
    
    % Place the elevation scroll bar just to the right of the colorbar.
    elevationPos = abutRight( colorbarPos, vscrollwidth );
    set( handles.elevation, 'Position', elevationPos + [ 0 -1 0 1 ] );
    
    % Place the roll scroll bar just to the right of the elevation scrollbar.
    rollPos = abutRight( elevationPos, vscrollwidth );
    set( handles.roll, 'Position', rollPos + [ 0 -1 0 1 ] );
    
    colortexthipos = abutRect( rollPos, 'en', colorbartextgap, colorbartextwidth, colorbartextheight );
    colortextlopos = abutRect( rollPos, 'es', colorbartextgap, colorbartextwidth, colorbartextheight );
    colornamehipos = abutRect( colortexthipos, 'sw', 2, colorbartextheight, colorbartextwidth );
    colornamelopos = abutRect( colortextlopos, 'nw', 2, colorbartextheight, colorbartextwidth );
    colortitlepos = abutRect( colornamehipos, 'sw', colorbartextgap, colorbartextheight, colorbartextwidth );
    azimuthtextpos = abutRect( colortitlepos, 'sw', colorbartextgap, colorbartextheight, colorbartextwidth );
    elevationtextpos = abutRect( azimuthtextpos, 'sw', colorbartextgap, colorbartextheight, colorbartextwidth );
    rolltextpos = abutRect( elevationtextpos, 'sw', colorbartextgap, colorbartextheight, colorbartextwidth );

    set( handles.colortexthi, 'Position', colortexthipos );
    set( handles.colornamehi, 'Position', colornamehipos );
    set( handles.colortitle, 'Position', colortitlepos );
    set( handles.colornamelo, 'Position', colornamelopos );
    set( handles.colortextlo, 'Position', colortextlopos );
    set( handles.colortitle, 'Position', colortitlepos );
    set( handles.azimuthtext, 'Position', azimuthtextpos );
    set( handles.elevationtext, 'Position', elevationtextpos );
    set( handles.rolltext, 'Position', rolltextpos );
    
    % Place the reset view button just below the first vertical scroll bar.
    resetViewPos = abutBelow( elevationPos, hscrollheight );
    set( handles.resetViewControl, 'Position', resetViewPos );

    % Place the roll-zero button just below the second vertical scroll bar.
    rollzeroPos = abutBelow( rollPos, hscrollheight );
    set( handles.rollzeroControl, 'Position', rollzeroPos );

    if false
        fprintf( 1, 'azimuth   [%d %d %d %d]\n', get( handles.azimuth, 'Position' ) );
        fprintf( 1, 'resetview [%d %d %d %d]\n', get( handles.resetViewControl, 'Position' ) );
        fprintf( 1, 'rollzero  [%d %d %d %d]\n', get( handles.rollzeroControl, 'Position' ) );
        fprintf( 1, 'picture   [%d %d %d %d]\n', get( handles.picture, 'Position' ) );
        fprintf( 1, 'colorbar  [%d %d %d %d]\n', get( handles.colorbar, 'Position' ) );
        fprintf( 1, 'picbkgnd  [%d %d %d %d]\n', get( handles.pictureBackground, 'Position' ) );
        fprintf( 1, 'picpanel  [%d %d %d %d]\n', get( handles.picturepanel, 'Position' ) );
        fprintf( 1, 'elevation [%d %d %d %d]\n', get( handles.elevation, 'Position' ) );
        fprintf( 1, 'roll      [%d %d %d %d]\n', get( handles.roll, 'Position' ) );
    end
end

function pos1 = abutRight( pos, width )
    pos1 = [ pos(1)+pos(3), pos(2), width, pos(4) ];
end

function abutControlRight( h1, h2 )
    pos1 = get( h1, 'Position' );
    pos2 = get( h2, 'Position' );
    pos2new = abutRight( pos1, pos2(3) );
    set( h2, 'Position', pos2new );
end

function pos1 = abutBelow( pos, height )
    pos1 = [ pos(1), pos(2)-height, pos(3), height ];
end

function abutControlBelow( h1, h2 )
    pos1 = get( h1, 'Position' );
    pos2 = get( h2, 'Position' );
    pos2new = abutBelow( pos1, pos2(4) );
    set( h2, 'Position', pos2new );
end

function r = insetRect( r1, r2 )
    if length(r2)==1
        r2 = [ r2, r2, r2, r2 ];
    end
    r = [ r1(1) + r2(1), r1(2) + r2(2), r1(3) - r2(3), r1(4) - r2(4) ];
end

function r = insetChildRect( r1, r2 )
    if length(r2)==1
        r2 = [ r2, r2, r2, r2 ];
    end
    r = [ r2(1), r2(2), r1(3) - r2(1) - r2(3), r1(4) - r2(2) - r2(4) ];
end

function insetControl( h1, h2, r )
    pos1 = get( h1, 'Position' );
    pos2new = insetChildRect( pos1, r );
    set( h2, 'Position', pos2new );
end
