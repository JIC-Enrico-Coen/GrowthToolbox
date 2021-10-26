function [handles,valid] = indicateInteractionValidity( handles, valid )
    if nargin < 2
        valid = isempty( handles.mesh ) || handles.mesh.globalProps.interactionValid;
    elseif ~isempty( handles.mesh )
        handles.mesh.globalProps.interactionValid = valid;
    end
    if valid
        color = [0 0 0];
    else
        color = [1 0 0];
    end
    set( handles.mgenInteractionName, 'ForegroundColor', color );
    ic = get( handles.interactionPanel, 'Children' );
    for i=1:length(ic)
        if valid
            restoreColor( ic(i) );
        else
            tryset( ic(i), 'ForegroundColor', color );
        end
    end
    if false
        if valid
            restoreColor( handles.editMgenInteractionButton );
            restoreColor( handles.initialiseIFButton );
        else
            set( handles.editMgenInteractionButton, 'ForegroundColor', color );
            set( handles.initialiseIFButton, 'ForegroundColor', color );
        end
    end
end
