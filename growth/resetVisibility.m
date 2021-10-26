function resetVisibility( handles )
%resetVisibility( handles )
%   Set the proper visibility of all GUI items.  Required when print()
%   corrupts the GUI by making everything visible.

    if ishandle( handles )
        handles = guidata( handles );
    end
    if isfield( handles, 'toolSelect' )
        selectCurrentTool( handles );
    end
    if isfield( handles, 'junkPanel' )
        makeCompletelyInvisibleDammit( handles.junkPanel );
    end
end

function makeCompletelyInvisibleDammit( h )
    set( h, 'Visible', 'off' );
    c = get( h, 'Children' );
    for i=1:length(c)
        makeCompletelyInvisibleDammit( c(i) );
    end
end
