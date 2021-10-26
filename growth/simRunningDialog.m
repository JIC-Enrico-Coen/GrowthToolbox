function simRunningDialog( msg )
    beep;
    uiwait( msgbox( msg, 'Simulation running', 'error', 'modal' ) );
end
