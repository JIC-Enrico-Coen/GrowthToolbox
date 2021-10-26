function normaliseGUIItemSize( h )
    e = get( h, 'Extent' );
    p = get( h, 'Position' );
    set( h, 'Position', [p([1 2]), max(e([3 4]),p([3 4]))], 'Visible', 'on' );
end
