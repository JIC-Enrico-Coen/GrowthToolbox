function modalOpeningFcn(hObject, eventdata, handles, varargin)
    % Choose default command line output for timeunitDlg
    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Make the GUI modal
    set(handles.figure1,'WindowStyle','modal');

    % UIWAIT makes timeunitDlg wait for user response (see UIRESUME)
    uiwait(handles.figure1);
end
