function s = getRSSSPositions( s )
    if strcmp( s.type, 'menu' )
        s.attribs.position = [];
    elseif ~isempty( s.handle )
        s.attribs.position = get( s.handle, 'Position' );
        switch s.type
            case { 'figure', 'panel', 'radiogroup', 'group', 'slider' }
                % Nothing.
            otherwise
                s.attribs.minsize = max( s.attribs.minsize, s.attribs.position([3 4]) );
        end
    end
    for i=1:length(s.children)
        s.children{i} = getRSSSPositions( s.children{i} );
    end
end
