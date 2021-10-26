function mouseCellModeMenu_Callback(hObject, eventdata, handles)
% --- Executes on selection change in mouseCellModeMenu.
    label = getMenuSelectedLabel( hObject );
    if ~strcmp( label, '----' )
        turnOffViewControl( handles );
    end
    fprintf( 1, 'mouseCellModeMenu_Callback %s\n', label );
    handles = establishInteractionMode( handles );
%    setMenuSelectedLabel( handles.mouseeditmodeMenu, '----' );
    guidata( handles.output, handles );


