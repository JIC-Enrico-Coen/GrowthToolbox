function deleteMenuItems( menuhandle )
    c = get( menuhandle, 'Children' );
    for i=1:length(c)
        delete( c(i) );
    end
end
