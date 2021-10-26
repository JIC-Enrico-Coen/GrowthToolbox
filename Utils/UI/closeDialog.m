function closeDialog(hObject)
    handles = guidata( hObject );
    if isempty(handles)
        delete( hObject );
    else
        dlg = getRootHandle(hObject);
        if isequal(get(dlg, 'waitstatus'), 'waiting')
            % The GUI is still in UIWAIT, use UIRESUME
            uiresume(dlg);
        else
            % The GUI is no longer waiting, just close it
            delete(dlg);
        end
    end
end
