function notifyPlotChangeFromGUIBool( handles, fn, hObject )
    notifyPlotChange( handles, fn, get(hObject,'Value') ~= 0 );
end
