function setMenuSelectedLabel( menu, label )
    item = 0;
    itemNames = get( menu, 'String' );
    if ischar( label )
        for i=1:length(itemNames)
            if strcmp( label, itemNames{i} )
                item = i;
                break;
            end
        end
    else
        item = label;
    end
    if (item >= 1) && (item <= length(itemNames))
        set( menu, 'Value', item );
    end
end
