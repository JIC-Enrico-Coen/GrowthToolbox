function ok = isMenuSelectedLabel( menu, label )
    label1 = getMenuSelectedLabel( menu );
    ok = strcmp( label, label1 );
end
