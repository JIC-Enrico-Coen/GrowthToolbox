function ok = selectMenuByLabel( menu, label )
    index = getMenuIndexFromLabel( menu, label );
    ok = index > 0;
    if ok
        set( menu, 'Value', index );
    end
end
