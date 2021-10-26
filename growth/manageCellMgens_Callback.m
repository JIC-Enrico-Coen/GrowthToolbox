function manageCellMgens_Callback()
%manageCellMgens_Callback()
%   Callback for the New/Delete/Rename buttons in the cellular morphogens
%   panel.

    [clickedItem,tag,fig,handles] = getGFtboxFigFromGuiObject();
    if isempty( handles.mesh ), return; end
    switch tag
        case 'new'
            % Make a dialog asking for new morphogen names.
            xx = performRSSSdialogFromFile('newcellmgens_layout.txt', ...
                    [], [], @(h)setGFtboxColourScheme( h, handles ) );
            if ~isempty(xx) && ~isempty(xx.lb) && ~isempty(xx.lb.strings)
                % New morphogens are in the cell array xx.lb.strings.
                attemptCommand( handles, true, true, 'add_cellfactor', xx.lb.strings{:} );
            end
        case 'del'
            selectedName = getMenuSelectedLabel( handles.displayedCellMgenMenu );
            attemptCommand( handles, true, true, 'delete_cellfactor', selectedName );
        case 'ren'
            oldname = getMenuSelectedLabel( handles.displayedCellMgenMenu );
            if ~strcmp( oldname, ' ' )
                queryString = sprintf( 'Rename cellular value "%s" to:', oldname );
                newname = askForString( 'Rename cellular value', queryString, oldname );
                if ~isempty( newname )
                    attemptCommand( handles, true, true, 'rename_cellfactor', oldname, newname );
                end
            end
        otherwise
            % Ignore.
    end
end
