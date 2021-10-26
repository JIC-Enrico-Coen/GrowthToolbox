function restoreColor( h )
%restoreColor( h )
%   Set the BackgroundColor of h to the value saved in the UserData.

    ud = get( h, 'UserData' );
    if isfield( ud, 'BackgroundColor' )
        set( h, 'BackgroundColor', ud.BackgroundColor );
    end
    if isfield( ud, 'ForegroundColor' )
        set( h, 'ForegroundColor', ud.ForegroundColor );
    end
    if isfield( ud, 'Color' )
        set( h, 'Color', ud.Color );
    end
end
