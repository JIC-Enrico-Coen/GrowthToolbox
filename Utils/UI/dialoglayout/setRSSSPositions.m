function setRSSSPositions( s )
    if strcmp( s.type, 'menu' )
        return;
    end
    if ~isempty( s.handle )
        switch s.type
            case 'axes'
                set( s.handle, 'OuterPosition', s.attribs.position );
            otherwise
                set( s.handle, 'Position', s.attribs.position );
        end
    end
    for i=1:length(s.children)
        setRSSSPositions( s.children{i} );
    end
end
