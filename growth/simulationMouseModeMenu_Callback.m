function simulationMouseModeMenu_Callback(hObject, eventdata, handles)
% --- Executes on selection change in simulationMouseModeMenu.
    label = getMenuSelectedLabel( hObject );
    if ~strcmp( label, '----' )
        turnOffViewControl( handles );
    end
    fprintf( 1, 'simulationMouseModeMenu_Callback %s\n', label );
    handles = establishInteractionMode( handles );
    guidata( handles.output, handles );


