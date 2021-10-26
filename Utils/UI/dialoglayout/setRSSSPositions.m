function setRSSSPositions( s )
    if strcmp( s.type, 'menu' )
        return;
    end
    if ~isempty( s.handle )
        set( s.handle, 'Position', s.attribs.position );
    end
    for i=1:length(s.children)
        setRSSSPositions( s.children{i} );
    end
end
