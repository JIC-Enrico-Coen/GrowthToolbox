function h = makeStaticText( parent, position, initstring, varargin )
    h = uicontrol( ...
            'Parent', parent, ...
            'Style', 'text', ...
            'String', initstring, ...
            'HorizontalAlignment', 'left', ...
            'Visible', 'off', ...
            varargin{:}  );
    e = get( h, 'Extent' );
    p = get( h, 'Position' );
    set( h, 'Position', [p([1 2]), e([3 4])], 'Visible', 'on' );
    color = tryget( parent, 'Color' );
    if isempty(color)
        color = tryget( parent, 'BackgroundColor' );
    end
    if ~isempty(color)
        set( h, 'BackgroundColor', color );
    end
end
