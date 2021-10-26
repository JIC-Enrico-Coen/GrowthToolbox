function b = selectButton( onButton, buttons )
%selectButton( onButton, buttons )
%   onButton is a radio button or checkbox and buttons is an array of buttons
%   of checkboxes which includes onButton.
%   None of the buttons should belong to a button group.  This routine
%   creates the effect of a button group: onButton is set to on and all the
%   other buttons are set to off.  The result is the index of onButton in
%   buttons.  If onButton is not in the list, the result is zero.
%
%   All of the buttons in such a pseudo-group should have the same
%   callback function.  This function should call SELECTBUTTON, passing the
%   current handle as the first argument and a list of all the buttons in
%   the group as the second.  The result tells it which button was clicked.
%
%   If the result is zero, this means that the currently selected button
%   was clicked, and was a radio button.  No action should be taken.
%   If the result is negative, this means that the currently selected button
%   was clicked, and was a checkbox, whose index is minus the return value.
%
%   See also: WHICHBUTTON

    b = 0;
    isradiobutton = strcmp( get( onButton, 'Style' ), 'radiobutton' );
    if isradiobutton && (get(onButton,'Value')==0)
        set( onButton, 'Value', 1 );
        return;
    end
    for i=1:numel(buttons)
        if onButton == buttons(i)
            if get( onButton, 'Value' )==1
                b = i;
            else
                b = -i;
            end
        else
            set( buttons(i), 'Value', 0 );
        end
    end
end
