function [tag,value] = getDialogItemData( h )
    tag = '';
    value = [];
    if numel(h) > 1
        value = cell( 1, numel(h) );
        for i=1:numel(h)
            [tag,value{i}] = getDialogItemData( h(i) );
        end
        if isempty(tag)
            value = '';
        end
        return;
    end
    tag = tryget(h,'Tag');
    if isempty(tag) || ~isempty( regexp( tag, '^X_', 'once' ) )
        % An item whose tag is either empty or begins with "X_" is one that
        % we are not interested in.
        tag = '';
        return;
    end
    type = tryget(h,'Type');
    hstyle = tryget(h,'Style');
    if isempty(hstyle)
        hstyle = '';
    end
    switch hstyle
        case { 'pushbutton' }
            tag = '';
        case { 'togglebutton', 'checkbox', 'radiobutton' }
            value = get(h,'Value');
        case { 'slider' }
            % Need to handle the case of linked slider and text.
            value = get(h,'Value');
        case { 'edit' }
            % Need to handle the case of linked slider and text,
            % and the case where the text is required to be a
            % number.
            value = get(h,'String');
        case { 'text' }
            % Need to handle the case of linked slider and text,
            % and the case where the text is required to be a
            % number.
            if ~isempty( get( h, 'Tag' ) )
                value = get(h,'String');
            end
        case { 'listbox', 'popupmenu' }
            values = get(h,'Value');
            strings = get(h,'String');
            value.values = values;
            value.strings = strings;
        case ''
            switch type
                case 'uibuttongroup'
                    selectedButton = get( h, 'SelectedObject' );
                    value = get( selectedButton, 'Tag' );
                otherwise
                    tag = '';
            end
        otherwise
            tag = '';
    end
end
