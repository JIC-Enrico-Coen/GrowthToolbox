function s = menuPath( menu )
    if ~ishandle(menu)
        s = '';
        return;
    end
    if ~strcmp( get( menu, 'Type' ), 'uimenu' )
        s = '';
        return;
    end
    p = get( menu, 'Parent' );
    sp = menuPath( p );
    s = get( menu, 'Label' );
    if ~isempty(sp)
        s = [ sp, ' > ', s ];
    end
end
