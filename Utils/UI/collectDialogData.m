function s = collectDialogData( handles )
    s = struct();
    fns = fieldnames( handles );
    for fni=1:length(fns)
        fn = fns{fni};
        h = handles.(fn);
        if ishandle( h )
            [tag,value] = getDialogItemData( h );
            if ~isempty(tag)
                s.(tag) = value;
            end
            if strcmp( get( h, 'Type' ), 'figure' )
                s.userdata = get( h, 'UserData' );
            end
        end
    end
    %handles.userdata = get( 
end
