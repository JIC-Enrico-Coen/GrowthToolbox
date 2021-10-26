function exitDialog( uiitem, success )
    handles = guidata( uiitem );
    if ~isempty( handles )
        if success
            handles.output = collectDialogData( handles );
            handles.output.userdata = get( ancestor(uiitem,'figure'), 'userdata' );
        else
          % handles.output = [];
        end
        guidata(gcbo, handles);
    end
    if isempty(handles)
        delete(getRootHandle(uiitem));
    else
        uiresume(ancestor(uiitem,'figure'));
    end
end
