function h = makeEditableText( fig, tag, pos, inittext, multiline, varargin )
%h = makeEditableText( fig, pos, tag, inittext, multiline )
%   Make a standard editable text object.

    if (nargin < 2) || isempty(pos)
        pos = [20 20 60 20];
    end
    if (nargin < 3) || isempty(tag)
        tag = '';
    end
    if (nargin < 4) || isempty(inittext)
        inittext = '';
    end
    if (nargin < 5) || isempty(multiline)
        multiline = false;
    end
    if multiline
        maxval = 2;
        halign = 'left';
    else
        maxval = 1;
        halign = 'center';
    end
    h = uicontrol( fig, ...
            'Style', 'edit', ...
            'Tag', tag, ...
            'Units', 'pixels', 'Position', pos, ...
            'Callback', 'checkTerminationKey(gcbo)', ...
            'CreateFcn', '', ...
            'BackgroundColor','white', ...
            'HorizontalAlignment', halign, ...
            'String', inittext, ...
            'Min', 0, ...
            'Max', maxval, ...
            varargin{:} );
    p = get( h, 'Position' );
    e = get( h, 'Extent' );
    fh = get( h, 'FontSize' );
    p(3) = max( [p(3),e(3)] );
    p(4) = max( [p(4),e(4),fh+16] );
    set( h, 'Position', p, 'Visible', 'on' );
end
