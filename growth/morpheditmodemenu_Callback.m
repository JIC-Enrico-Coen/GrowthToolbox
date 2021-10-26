function morpheditmodemenu_Callback(hObject, eventdata, handles)
    label = getMenuSelectedLabel( handles.morpheditmodemenu );
    if ~strcmp( label, '----' )
        turnOffViewControl( handles );
    end
    fprintf( 1, 'morpheditmodemenu_Callback %s\n', label );
    handles = establishInteractionMode( handles, ...
        getDisplayedMgenIndex( handles ), ...
        getDoubleFromDialog( handles.paintamount ) );
    guidata( handles.output, handles );


