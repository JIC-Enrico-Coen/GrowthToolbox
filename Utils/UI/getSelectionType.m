function selectionType = getSelectionType( hitObject )
%selectionType = getSelectionType( hitObject )
% Get the mouse/keyboard modifier information for a click on an object
% contained in an axes contained in a figure.  We have to hunt up the chain
% of parents to find the object that has the SelectionType information.

    currentObject = hitObject;
    while ~isempty(currentObject)
        try
            selectionType = get( currentObject, 'SelectionType' );
            return;
        catch e %#ok<NASGU>
            currentObject = get( currentObject, 'Parent' );
        end
    end
    fprintf( 1, 'WARNING: Cannot find SelectionType of %s %f.\n', ...
        get( hitObject, 'Type' ), hitObject );
    selectionType = [];
end
