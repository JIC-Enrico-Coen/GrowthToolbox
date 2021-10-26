function wasBusy = setGFtboxBusy( handles, isBusy )
%wasBusy = setGFtboxBusy( handles, isBusy )
%   Set the busy flag and return its previous value.
%   To ensure that the busy flag displays during execution of a block of
%   code, bracket it like this:
%
%       wasBusy = setGFtboxBusy( handles, true );
%
%       ...your code...
%
%       setGFtboxBusy( handles, wasBusy );
%
%   This ensures that whatever value it had previously is restored.

    if isempty(handles)
        wasBusy = false;
        return;
    end

    wasBusy = ishandle(handles.busyPanel) && strcmp( get( handles.busyPanel, 'Visible' ), 'on' );
    if wasBusy ~= isBusy
      % fprintf( 1, 'Setting BUSY to %d\n', isBusy );
      % dbstack;
        visstring = boolchar( isBusy, 'on', 'off' );
        set( handles.busyPanel, 'Visible', visstring );
        c = get( handles.busyPanel, 'Children' );
        set( c, 'Visible', visstring );
        drawnow;
    end
end
