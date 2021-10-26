function label = getExclusiveMenuItem( items )
    for i=1:length(items)
        if strcmp( get( items(i), 'Checked' ), 'on' )
            label = get( items(i), 'Label' );
            return;
        end
    end
    label = '';
end
