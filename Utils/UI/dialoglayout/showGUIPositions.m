function showGUIPositions( item, indent )
    if nargin < 2
        indent = 0;
    end
    fprintf( 1, '%s', repmat( '-', 1, indent*4 ) );
    fprintf( 1, ' %d', ceil(item.outerposition) );
    fprintf( 1, '        [' );
    fprintf( 1, ' %d', ceil(item.position) );
    fprintf( 1, '] [' );
    fprintf( 1, ' %d', item.sticky );
    fprintf( 1, '] e [%d %d %d %d] s%d', item.edge, item.separation );
    if isfield( item, 'handle' ) && ishandle( item.handle )
        kind = tryget( item.handle, 'Style' );
        if isempty(kind)
            kind = tryget( item.handle, 'Type' );
        end
        if ~isempty(kind)
            fprintf( 1, ' %s', kind );
        end
        fprintf( 1, ' %s', get(item.handle,'Tag') );
    end
    fprintf( 1, '\n' );
    for i=1:length(item.children)
        showGUIPositions( item.children{i}, indent+1 );
    end
end

