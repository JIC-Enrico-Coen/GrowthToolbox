function keyPanelSwitch( handles, keystroke, modbits )
    if isfield( handles.panelSwitchInfo, keystroke )
        buttontag = handles.panelSwitchInfo.(keystroke);
        set( handles.toolSelect, 'SelectedObject', handles.(buttontag) );
        selectCurrentTool( handles )
    end
end
