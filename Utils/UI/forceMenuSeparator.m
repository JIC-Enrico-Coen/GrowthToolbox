function forceMenuSeparator( h )
%forceMenuSeparator( h )
%   This is a workaround for a bug in Matlab 2010a on Mac OS, whereby in
%   some circumstances, menu separators fail to appear even though the
%   'Separator' attribute of the menu handle is properly set.

    drawnow;
    set( h, 'Separator', 'off' );
    set( h, 'Separator', 'on' );
end
