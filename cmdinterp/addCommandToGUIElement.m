function addCommandToGUIElement( h, cmd, requiresMesh, args )
%addCommandToGUIElement( h, cmd, requiresMesh, args )
%   Add the CMD, REQUIRESMESH flag, and cellarray ARGS to the UserData
%   element of the GUI component H.

    %   We have to wrap ARGS as {ARGS} below, to avoid the special-case
    %   treatment of cell arrays by STRUCT.
    c = get( h, 'UserData' );
    newcmd = struct( 'cmd', cmd, 'requiresMesh', requiresMesh, 'args', {args} );
    
    % The conditional here is necessary because you can't assign a
    % structure to a variable containing an empty array.
    if isempty(c)
        c = newcmd;
    else
        c(end+1) = newcmd;
    end
    
    set( h, 'UserData', c );
end
