function [nowSelected,selectionType] = selectGraphicObject( hitObject )
    nowSelected = ~strcmp( 'on', get( hitObject, 'Selected' ) );
    if nowSelected
        set( hitObject, 'Selected', 'on' );
    else
        set( hitObject, 'Selected', 'off' );
    end
  % isHighlighted = get( hitObject, 'SelectionHighlight' );
    parent = get( hitObject, 'Parent' );
    grandparent = get( parent, 'Parent' );
    selectionType = get( grandparent, 'SelectionType' );
    nowSelected = ~nowSelected;
end
