function editCurrentCellMgen_Callback( varargin )
%editCurrentCellMgen_Callback()
%   Callback for the controls in the cellular morphogens panel that change
%   the value of the currently selected morphogen.

    [clickedItem,tag,fig,handles,panelfig,panelhandles] = getGFtboxFigFromGuiObject();
    if isempty( handles.mesh ), return; end
    if ~hasNonemptySecondLayer( handles.mesh ), return; end
    
    if strcmp( tag, 'zeroall' )
        attemptCommand( handles, true, true, 'zero_cellfactors' );
        return;
    end
        
    
    % Find the current morphogen.  If none, return.
    selmgenname = getMenuSelectedLabel( handles.displayedCellMgenMenu );
    selmgenindex = name2Index( handles.mesh.secondlayer.valuedict, selmgenname );
    if selmgenindex==0
        return;
    end
    hfig = guidata(clickedItem);
    amount = getDoubleFromString( 'cellular factor', get( hfig.editamount, 'String' ) );
    centre = [ getDoubleFromString( 'cellular factor', get( hfig.editx, 'String' ) ), ...
               getDoubleFromString( 'cellular factor', get( hfig.edity, 'String' ) ), ...
               getDoubleFromString( 'cellular factor', get( hfig.editz, 'String' ) ) ];
    direction = getDoubleFromString( 'cellular factor', get( hfig.editdir, 'String' ) );

    attemptCommand( handles, true, true, 'set_cellfactor', ...
            'factor', selmgenindex, ...
            'operation', tag, ...
            'amount', amount, ...
            'centre', centre, ...
            'direction', direction, ...
            'add', true );
end
