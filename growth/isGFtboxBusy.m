function isBusy = isGFtboxBusy( handles )
%isBusy = isGFtboxBusy( handles )
%   Determine whether the busy flag is set.

    isBusy = ishandle(handles.busyPanel) && strcmp( get( handles.busyPanel, 'Visible' ), 'on' );
end
