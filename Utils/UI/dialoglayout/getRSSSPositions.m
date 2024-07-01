function s = getRSSSPositions( s )
    if strcmp( s.type, 'menu' )
        s.attribs.position = [];
    elseif ~isempty( s.handle )
        s.attribs.position = get( s.handle, 'Position' );
        switch s.type
            case { 'figure', 'panel', 'radiogroup', 'group', 'slider', 'xlabel', 'ylabel', 'zlabel' }
                % Nothing.
            otherwise
                if size( s.attribs.position, 2 ) >= 4
                    s.attribs.minsize = max( s.attribs.minsize, s.attribs.position([3 4]) );
                end
        end
    end
    for i=1:length(s.children)
        s.children{i} = getRSSSPositions( s.children{i} );
    end
end
