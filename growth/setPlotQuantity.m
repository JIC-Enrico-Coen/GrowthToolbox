function setPlotQuantity( handles, which )
    index = getMenuIndexFromLabel( handles.newplotQuantityMenu, which );
    itemNames = get( handles.newplotQuantityMenu, 'String' );
    if (index > length(itemNames)) || (index <= 0)
        fprintf( 1, 'ERROR IN setPlotQuantity: index %d, length %d.\n', index, length(itemNames) );
    else
        set( handles.newplotQuantityMenu, 'Value', index );
    end
end
