function mouseeditmodeMenu_Callback(hObject, eventdata, handles)
% --- Executes on selection change in mouseeditmodeMenu.
    label = getMenuSelectedLabel( handles.mouseeditmodeMenu );
    if ~strcmp( label, '----' )
        turnOffViewControl( handles );
    end
    visfixedboxes = boolchar( strcmp( label, 'Fix nodes' ) || strcmp( label, 'Locate node' ), 'on', 'off' );
    set( handles.fixXbox, 'Visible', visfixedboxes );
    set( handles.fixYbox, 'Visible', visfixedboxes );
    set( handles.fixZbox, 'Visible', visfixedboxes );
    set( handles.unfixallButton, 'Visible', visfixedboxes );

    handles = establishInteractionMode( handles );
    guidata( hObject, handles );
end
