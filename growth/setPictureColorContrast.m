function setPictureColorContrast( pichandles, c )
%setPictureColorContract( pichandles, c )
%   Set the background colour to c, and the foreground colour (the colour
%   of the axes, the legend, etc.) to a colour contrasting with c.

    if ~ishandle( pichandles.picture )
        return;
    end
    elementColor = contrastColor( c );
    setGUIElementColor( pichandles.picture, c );
    setGUIElementColor( pichandles.pictureBackground, c );
    setGUIElementColor( get(pichandles.picture,'Parent'), c );
    if ishandle(pichandles.legend)
        set( pichandles.legend, ...
             'BackgroundColor', c, ...
             'ForegroundColor', elementColor );
    end
    if hashandle(pichandles, 'scalebar')
        set( pichandles.scalebar, ...
             'BackgroundColor', elementColor, ...
             'ForegroundColor', c ); 
    end
    set( pichandles.picture, ...
         'XColor', elementColor, ...
         'YColor', elementColor, ...
         'ZColor', elementColor );
    xaxis = get(pichandles.picture,'XLabel');
    yaxis = get(pichandles.picture,'YLabel');
    zaxis = get(pichandles.picture,'ZLabel');
    set(xaxis, 'Color', elementColor );
    set(yaxis, 'Color', elementColor );
    set(zaxis, 'Color', elementColor );
    setGUIElementColor( pichandles.colorbar, c )
end
