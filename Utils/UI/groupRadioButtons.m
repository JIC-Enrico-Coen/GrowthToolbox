function groupRadioButtons( buttons )
    for i=1:length(buttons)
        ud = get( buttons(i), 'UserData' );
        if isempty(ud) || ~isstruct(ud)
            set( buttons(i), 'UserData', struct( 'groupmembers', buttons ) );
        else
            ud.groupmembers = buttons;
            set( buttons(i), 'UserData', ud );
        end
        set( buttons(i), 'Callback', @radioButtonCallback );
    end
end

function radioButtonCallback( b, eventData )
    if isempty(b), return; end
    ud = get( b, 'UserData' );
    if isempty(ud), return; end
    if ~isstruct(ud), return; end
    if ~isfield( ud, 'groupmembers' ), return; end
    if get(b,'Value')==1
        for i=1:length(ud.groupmembers)
            if ud.groupmembers(i) ~= b
                set( ud.groupmembers(i), 'Value', 0 );
            end
        end
    else
        set( b, 'Value', 1 );
    end
end
