function enableGUIitem( itemHandle, enable )
    if enable
        set( itemHandle, 'Enable', 'on' );
    else
        set( itemHandle, 'Enable', 'off' );
    end
end
