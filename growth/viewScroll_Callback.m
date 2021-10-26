function viewScroll_Callback(hObject, eventdata)
    h = guidata( hObject );
    [oldaz,oldel,oldroll] = getview( h.picture );
    newaz = -get( h.azimuth, 'Value' );
    newel = -get( h.elevation, 'Value' );
    newroll = -get( h.roll, 'Value' );
    set( hObject, 'UserData', 1 );  % Flag to indicate user action.
    if (oldaz ~= newaz) || (oldel ~= newel) || (oldroll ~= newroll)
      % setview( h.picture, newaz, newel, newroll );
        attemptCommand( guidata(hObject), false, false, ...
                'plotoptions', ...
                'azimuth', newaz, ...
                'elevation', newel, ...
                'roll', newroll );
    end
end
