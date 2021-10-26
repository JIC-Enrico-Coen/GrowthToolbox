function label = getMenuSelectedLabel( menu )
    itemIndex = getMenuSelectedIndex( menu );
    label = getMenuLabelFromIndex( menu, itemIndex );
    if strcmp( label, ' ' )
        label = '';
    end
end
