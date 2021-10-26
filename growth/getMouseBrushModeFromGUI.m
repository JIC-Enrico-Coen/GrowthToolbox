function brushmode = getMouseBrushModeFromGUI( handles )
    switch getExclusiveButtonItem( ...
        [ handles.mouseClickIconButton, ...
          handles.mouseBoxIconButton, ...
          handles.mouseBrushIconButton ] )
        case 1
            brushmode = 'Click';
        case 2
            brushmode = 'Box';
        case 3
            brushmode = 'Brush';
        otherwise
            brushmode = '----';
    end
end
