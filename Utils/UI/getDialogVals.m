function vals = getDialogVals( h, vals )
%vals = getDialogVals( h )
%   Collect all of the state information from a dialog, in the same form
%   that is would be returned from performRSSSdialogFromFile or supplies as
%   the initvals argument to performRSSSdialogFromFile or
%   modelessRSSSdialogFromFile.

    if nargin < 2
        vals = struct();
    end
    tag = get(h,'tag');
    if ~isempty(tag)
        type = get(h,'type');
        if strcmp( type, 'uicontrol' )
            type = get(h,'style');
        end
        switch type
            case { 'figure' }
                vals.(tag) = get(h,'name');
            case { 'text', 'edit' }
                vals.(tag) = get(h,'string');
            case { 'checkbox', 'togglebutton', 'radiobutton' }
                vals.(tag) = get(h,'value');
        end
    end
    c = get(h,'children');
    for i=1:length(c)
        vals = getDialogVals( c(i), vals );
    end
end
