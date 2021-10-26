function listGUIObjects( h, depth )
    if isempty(h)
        return;
    end
    if nargin < 2
        depth = 0;
    end
    if length(h) > 1
        for i=1:length(h)
            listGUIObjects( h(i), depth );
        end
    else
        tag = get(h,'Tag');
        if isempty(tag)
            tag = '-';
        end
        kind = tryget(h,'Style');
        if isempty(kind)
            kind = tryget(h,'Type');
        end
        pos = get(h,'Position');
        fprintf( 1, '%s%s %s [%d %d %d %d]\n', ...
            repmat( ' ', 1, depth*4 ), kind, tag, pos );
        listGUIObjects( get(h,'Children'), depth+1 );
    end
end
