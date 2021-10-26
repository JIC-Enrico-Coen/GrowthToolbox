function GFTwindow_KeyPressFcn(hObject,eventdata)
%GFTwindow_KeyPressFcn(hObject,eventdata)
%   Process keystroke events.

    % No longer used.
    return;

    handles = guidata( hObject );
    modbits = getModifiers( eventdata.Modifier )
    switch eventdata.Key
        case 'alt'
            return;
        case 'capslock'
            return;
        case 'control'
            return;
        case 'shift'
            return;
        case 'escape'
            f = handles.commandKeyFns{27};
            if ~isempty(f)
                f( handles, eventdata.Key, modbits );
            end
            return;
    end
    if modbits.control
        if length(eventdata.Key)==1
            keycode = int16( eventdata.Key );
            if (1 <= keycode) && (keycode <= 127) && ~isempty(handles.commandKeyFns{keycode})
                f = handles.commandKeyFns{keycode};
                f( handles, eventdata.Key, modbits );
            end
        end
    end
end

function modbits = getModifiers( mods )
    nummods = 4;
    modbits = struct( 'alt', false, ...
                      'capslock', false, ...
                      'control', false, ...
                      'shift', false );
    for i=1:length(mods)
        switch mods{i}
            case 'alt'
                modbits.alt = true;
            case 'capslock'
                modbits.capslock = true;
            case 'control'
                modbits.control = true;
            case 'shift'
                modbits.shift = true;
        end
    end
end
