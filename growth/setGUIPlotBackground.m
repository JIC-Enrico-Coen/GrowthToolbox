function setGUIPlotBackground( handles, color )
    othercolor = contrastColor( color );
    set( handles.picture, 'Color', color, 'XColor', othercolor, 'YColor', othercolor, 'ZColor', othercolor );
    set( handles.picturepanel, 'BackgroundColor', color );
    set( handles.pictureBackground, 'Color', color, 'XColor', color, 'YColor', color, 'ZColor', color );
    set( handles.legend, 'BackgroundColor', color, ...
                         'ForegroundColor', othercolor );
    set( handles.scalebar, 'BackgroundColor', othercolor, ...
                           'ForegroundColor', color );
%     if colorbar is blank
%         fillAxes( handles.colorbar, color );
%     end
end
