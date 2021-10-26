function ui = userinterrupt( sb )
%ui = userinterrupt( sb )
%   Detect that the user has clicked the stop button.  sb is the stop
%   button's graphics handle.

    drawnow;  % Needed in order to allow a user click to be processed.
    ui = ~isempty( sb ) && sb.Value;
end
