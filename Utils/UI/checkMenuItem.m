function checkMenuItem( menus, checked )
    checkedString = boolchar( checked, 'on', 'off' );
    for menu=menus
        set( menu, 'Checked', checkedString );
    end
end
