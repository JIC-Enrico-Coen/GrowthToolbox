function clearFlag( handles, flag )
    if ~isempty(handles) && isfield( handles, flag )
        set( handles.(flag), 'Value', 0 );
    end
end
