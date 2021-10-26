function index = getMenuIndexFromLabel( menu, label )
    itemNames = get( menu, 'String' );
    if ischar( itemNames )
        if strcmp(label,itemNames)
            index = 1;
        else
            index = 0;
        end
    else
        for i=1:length(itemNames)
            if strcmp( itemNames{i}, label )
                index = i;
                return;
            end
        end
        index = 0;
    end
end
