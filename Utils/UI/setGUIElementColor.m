function setGUIElementColor( h, c )
%setGUIElementColor( h, c )
%   Sets the colour of the GUI element H to color C, without caring whether
%   the relevant field is called 'Color' or 'BackgroundColor'.

    tryset( h, 'BackgroundColor', c );
    tryset( h, 'Color', c );
end
