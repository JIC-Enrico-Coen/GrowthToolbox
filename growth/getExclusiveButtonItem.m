function item = getExclusiveButtonItem( items )
    for i=1:length(items)
        if get( items(i), 'Value' )
            item = i;
            return;
        end
    end
    item = '';
end
