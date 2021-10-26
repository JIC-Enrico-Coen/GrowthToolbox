function c = getSelectedCompressor( codecMenu )
    menuItems = get(codecMenu,'Children');
    for i=1:length(menuItems)
        checked = get( menuItems(i), 'Checked' );
        if strcmp(checked,'on')
            c = get(menuItems(i), 'Label');
            return;
        end
    end
    c = 'None';
end
