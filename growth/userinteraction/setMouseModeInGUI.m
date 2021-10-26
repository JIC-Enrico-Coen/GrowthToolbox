function setMouseModeInGUI( handles, mode )
%setMouseModeInGUI( handles, mode )
%   This is called when the user has operated a GUI element that sets
%   the mouse mode.  It ensures that all of the other elements that can
%   indicate the mouse mode indicate that they are inactive.  These are the
%   view buttons and the menus of mouse interaction modes.

    isview = setViewButtons();
    if isview
        [menutag,menuHandle] = currentMouseMenu( handles );
        if ~isempty(menutag)
            setMenuSelectedLabel( handles.(menutag), '----' );
        end
    else
        turnOffViewControl( handles );
    end
    
function isview = setViewButtons()
    isview = false;
    for modename={ 'pan', 'zoom', 'rotate', 'rotupright' }
        on = strcmp( mode, modename{:} );
        set( handles.([modename{:} 'Toggle']), 'Value', on );
        if on, isview = true; end
    end;
end
end

