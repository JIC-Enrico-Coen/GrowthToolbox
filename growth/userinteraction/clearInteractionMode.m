function m = clearInteractionMode( m )
%m = clearInteractionMode( m )
%   Clear the interaction mode.
    m.interactionMode = struct();
    m.selection = emptySelection();
end
