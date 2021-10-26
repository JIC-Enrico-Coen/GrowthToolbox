function m = setPictureColor( m, c )
%m = setPictureColor( m, c )
%   Set the background colour to c, and the foreground colour (the colour
%   of the axes, the legend, etc.) to a colour contrasting with c.

    pictures = unique( m.pictures );
    pictures = pictures( ishandle( pictures ) );
    for i=1:length(pictures)
        pichandles = guidata( pictures(i) );
        setPictureColorContrast( pichandles, c );
    end
    m.plotdefaults.bgcolor = c;
end
