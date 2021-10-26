function mousemode = getMouseModeFromGUI( handles )
%mousemode = getMouseModeFromGUI( handles )
%   Find out from the GUI what the current effect of the mouse is.
%   If the current panel has a mouse mode menu, and it's selection is not
%   '----', then that is the mouse mode.  Otherwise, if a view button is
%   selected, that is the mouse mode.  Otherwise, '----'.

    if ~isfield( handles, 'mesh' ) || ~isinteractive( handles.mesh )
        mousemode = '----';
        return;
    else
        mouseMenuMode = currentMouseMenuSelection( handles );
        if strcmp( mouseMenuMode, '----' )
            mousemode = getSelectedViewButton( handles );
        else
            mousemode = mouseMenuMode;
        end
    end
end

function viewbutton = getSelectedViewButton( handles )
    for viewbutton1={ 'pan', 'zoom', 'rotate', 'rotupright' }
        viewbutton = viewbutton1{:};
        if get( handles.([viewbutton 'Toggle']), 'Value' )
            return;
        end
    end;
    viewbutton = '----';
end

function [mouseMenuSelection,menutag] = currentMouseMenuSelection( handles )
    [menutag,menuHandle] = currentMouseMenu( handles );
    if isempty( menutag )
        mouseMenuSelection = '----';
    else
        mouselabel = getMenuSelectedLabel( menuHandle );
        if strcmp( mouselabel, '----' )
            mouseMenuSelection = '----';
        else
            mouseMenuSelection = [ menutag, ':', getMenuSelectedLabel( menuHandle ) ];
        end
    end
end
