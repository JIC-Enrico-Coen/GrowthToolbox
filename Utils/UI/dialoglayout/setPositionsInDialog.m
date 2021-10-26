function setPositionsInDialog( item )
    setPositionsInDialogRec( item, [0 0] );
    figpos = get( item.parent, 'Position' );
    figpos([3,4]) = item.position([3,4]);
    set( item.parent, 'Position', figpos );
end

function setPositionsInDialogRec( item, offset )
    if nargin < 2
        offset = [0 0];
    end
    itempos = item.position + [ offset, 0, 0 ];
    if isfield( item, 'handle' )
        set( item.handle, 'Position', itempos );
        fprintf( 1, 'Setting %s to [%d %d %d %d]\n', get(item.handle, 'Tag' ), itempos );
        offset = [0 0];
    else
        offset = offset + item.position([1 2]);
    end
    for i=1:length(item.children)
        setPositionsInDialogRec( item.children{i}, offset );
    end
    if isfield( item, 'fig' )
        figpos = get( item.fig, 'Position' );
        figpos([3,4]) = item.position([3,4]);
        set( item.fig, 'Position', figpos );
    end
end
