function items = convertStringsToHandles( parent, items )
%items = convertStringsToHandles( parent, items )
%   items is a nested cell array of strings.  This procedure crawls over
%   the structure, replacing strings that it recognises by GUI handles
%   which it creates.  The recognised strings are:
%       'OK'
%       'Cancel'
%       'OKCancel'
%       all of the standard uicontrol type names
%   These are recognised when they occur as the first child of a parent
%   node.  For the first three, the other children are also processed. For
%   the last, the other children are interpreted as its parameters.

    if isempty(items)
        return;
    elseif iscell( items )
        if iscell( items{1} )
            items{1} = convertStringsToHandles( parent, items{1} );
            if isgroupinghandle( items{1} )
                parent = items{1};
            end
            for i=2:length(items)
                items{i} = convertStringsToHandles( parent, items{i} );
            end
        elseif ischar( items{1} )
            items = convertStringItemToHandle( parent, items );
        else
            complain( '%s: bad parameter.\n', mfilename() );
            items
        end
    elseif ischar( items )
        x = convertStringItemToHandle( parent, { items } );
        items = x{1};
    end
end

function items = convertNonParamsToHandle1( parent, items )
    for i=2:length(items)
        items{i} = convertStringsToHandles( parent, items{i} );
    end
end

function items = convertStringItemToHandle( parent, items )
    switch items{1}
        case 'OK'
            items{1} = makeOKButton( parent );
            items = convertNonParamsToHandle1( parent, items );
        case 'Cancel'
            items{1} = makeCancelButton( parent );
            items = convertNonParamsToHandle1( parent, items );
        case 'OKCancel'
            items{1} = { makeOKButton( parent ), makeCancelButton( parent ) };
            items = convertNonParamsToHandle1( parent, items );
        case 'pushbutton'
            if length(items) >= 2
                tag = items{2};
            else
                tag = '';
            end
            if length(items) >= 3
                title = items{3};
            else
                title = '';
            end
            if length(items) >= 4
                callback = items{4};
            else
                callback = [];
            end
            items = uicontrol( 'Style', 'pushbutton', ...
                               'Parent', parent, ...
                               'Tag', tag, ...
                               'String', title, ...
                               'Units', 'pixels', ...
                               'Position', [0 0 20 20], ...
                               'Callback', callback );
            normaliseGUIItemSize( items );
        case 'togglebutton'
            if length(items) >= 2
                tag = items{2};
            else
                tag = '';
            end
            if length(items) >= 3
                title = items{3};
            else
                title = '';
            end
            if length(items) >= 4
                state = items{4};
            else
                state = 0;
            end
            if length(items) >= 5
                callback = items{5};
            else
                callback = [];
            end
            items = uicontrol( 'Style', 'togglebutton', ...
                               'Parent', parent, ...
                               'Tag', tag, ...
                               'String', title, ...
                               'Value', state, ...
                               'Units', 'pixels', ...
                               'Position', [0 0 20 20], ...
                               'Callback', callback );
            normaliseGUIItemSize( items );
        case 'panel'
            if length(items) >= 2
                title = items{2};
            else
                title = '';
            end
            items = uipanel( 'Parent', parent, 'Title', title, 'Units', 'pixels', 'Position', [0 0 20 20] );
        case 'text'
            if length(items) >= 2
                inittext = items{2};
            else
                inittext = '';
            end
            items = makeStaticText( parent, [20 20 100 20], inittext );
        case 'edit'
            if length(items) >= 2
                tag = items{2};
            else
                tag = '';
            end
            if length(items) >= 3
                inittext = items{3};
            else
                inittext = '';
            end
            if length(items) >= 4
                multiline = items{4};
            else
                multiline = 0;
            end
            items = makeEditableText( parent, tag, [20 20 100 20], inittext, multiline, items{5:end} );
        otherwise
            complain( '%s: unknown item type %s.\n', ...
                mfilename(), items{1} );
            items = [];
    end
end

