function type = getMouseSelectionTypeFromGUI( handles )
    switch getExclusiveButtonItem( ...
        [ handles.mouseClickVertexButton, ...
          handles.mouseClickEdgeButton, ...
          handles.mouseClickFaceButton ] )
        case 1
            type = 'Vertex';
        case 2
            type = 'Edge';
        case 3
            type = 'Face';
        otherwise
            type = '----';
    end
end
