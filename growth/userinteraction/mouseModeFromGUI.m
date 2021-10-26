function mousemode = mouseModeFromGUI( handles )
%mousemode = mouseModeFromGUI( fig )
%   Discover the current mouse mode by inspecting the state of the GUI.
%   If any of the view buttons is highlighted, that is the mouse mode.
%   Otherwise, if a mouse mode menu is visible, it specifies the mode.
%   Otherwise, a default mode is selected.

    mousemode = '';
    if strcmp( get( handles.runsimpanel, 'Visible' ), 'on' ) % Mesh Editor panel is visibleget( handles.zoomToggle, 'Value' )
        mousemode = 'showvalue';
    elseif get( handles.panToggle, 'Value' )
        mousemode = 'pan';
    elseif get( handles.zoomToggle, 'Value' )
        mousemode = 'zoom';
    elseif get( handles.rotateToggle, 'Value' )
        mousemode = 'rotate';
    elseif get( handles.rotuprightToggle, 'Value' )
        mousemode = 'rotupright';
    elseif strcmp( get( handles.editorpanel, 'Visible' ), 'on' ) % Mesh Editor panel is visibleget( handles.zoomToggle, 'Value' )
        mousemode = getMenuSelectedLabel( handles.mouseeditmodeMenu );
    elseif strcmp( get( handles.morphdistpanel, 'Visible' ), 'on' ) % Mesh Editor panel is visibleget( handles.zoomToggle, 'Value' )
        label = getMenuSelectedLabel( handles.morpheditmodemenu );
        mousemode = ['morph' label];
    else
    end
%     fprintf( 1, 'mouseModeFromGUI = %s\n', mousemode );
end
