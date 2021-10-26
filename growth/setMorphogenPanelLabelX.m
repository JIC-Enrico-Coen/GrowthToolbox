function setMorphogenPanelLabel( h )
    mgenName = mgenNameFromMgenMenu( h );
    if isempty(mgenName)
        set( h.morphdistpanel, 'Title', 'Morphogens' );
    else
        set( h.morphdistpanel, 'Title', ['Morphogen: ', mgenName] );
    end
end
