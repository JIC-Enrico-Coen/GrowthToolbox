function askForLegend_getDefault( hObject, eventData )
    global gGlobalProps;
    h = guidata( hObject );
    set( h.editableText, 'String', gGlobalProps.legendTemplate );
end
