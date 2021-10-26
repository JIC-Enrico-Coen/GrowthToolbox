function stopButton_Callback(hObject, eventdata, handles)
% --- Executes on button press in stopButton.
    if isempty(handles.mesh) || (~get( handles.runFlag, 'Value' ))
        % set( hObject, 'Value', 0 );
    end
end
