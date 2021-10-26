function labels = getMenuLabelsFromIndex( menu, indexes )
    itemNames = get( menu, 'String' );
    if isempty( itemNames )
        % No labels.
        labels = {};
    elseif iscell(itemNames)
        % Cell array of labels.
        indexes = indexes( (indexes >= 1) & (indexes <= length(itemNames)) );
        labels = itemNames(indexes);
    else
        % itemNames must be a single string.  Shouldn't happen.
        if indexes==1
            % The only valid index for a single string.
            labels = { itemNames };
        else
            % Index out of range.
            labels = {};
        end
    end
end
