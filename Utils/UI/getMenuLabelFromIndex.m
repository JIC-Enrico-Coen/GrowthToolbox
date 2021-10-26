function label = getMenuLabelFromIndex( menu, index )
    itemNames = get( menu, 'String' );
    if isempty( itemNames )
        % No labels.
        label = '';
    elseif iscell(itemNames)
        % Cell array of labels.
        if (index < 1) || (index > length(itemNames))
            % Index out of range.
            label = '';
        else
            % Got a label!  This is the only good case.
            label = itemNames{index};
        end
    else
        % itemNames must be a single string.  Shouldn't happen.
        if index==1
            % The only valid index for a single string.
            label = itemNames;
        else
            % Index out of range.
            label = '';
        end
    end
end
