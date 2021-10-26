function b = whichButton( buttons )
%whichButton( buttons )
%   buttons is an array of radio buttons.
%   None of the buttons should belong to a button group.  This routine
%   creates the effect of a button group: it returns the index of the first
%   button that is set to on, or zero if there is no such button.
%
%   See also: SELECTBUTTON

    for i=1:numel(buttons)
        if get( buttons(i), 'Value' )==1
            b = i;
            return;
        end
    end
end
