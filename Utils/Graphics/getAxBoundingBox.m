function bbox = getAxBoundingBox( ax, varargin )
%bbox = getAxBoundingBox( ax, mode )
%   Find a bounding box for the axes object AX.
%
%   The bounding box can include the axis ranges of AX, the bounds of the
%   data plotted in AX, or both, according to MODE.
%
%   If MODE is 'axis', only the axis bounds are used. If MODE is 'data',
%   only the plotted data is used. If empty or omitted, both are used.

    bbox = [];
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'symmetric', false, 'data', '' );
    ok = checkcommandargs( mfilename(), s, 'only', ...
        'relmargin', 'absmargin', 'symmetric', 'data', 'centre' );
    if ~ok, return; end
    if isempty(s) || isempty(fieldnames(s))
        return;
    end

    
    if ~ishghandle(ax)
        return;
    end
    
    useAxisBbox = false;
    useDataBbox = false;
    switch s.data
        case 'axis'
            useAxisBbox = true;
        case 'data'
            useDataBbox = true;
        otherwise
            useAxisBbox = true;
            useDataBbox = true;
    end
    
    axisBbox = [];
    if useAxisBbox
        axisBbox = [ ax.XLim', ax.YLim', ax.ZLim' ];
    end
    
    dataBbox = [];
    if useDataBbox
        for ci=1:length(ax.Children)
            c = ax.Children(ci);
            try
                bbox1 = [ min(c.XData(:)), min(c.YData(:)), min(c.ZData(:));
                          max(c.XData(:)), max(c.YData(:)), max(c.ZData(:)) ];
                dataBbox = unionBbox( dataBbox, bbox1 );
            catch e
                % Ignore.
                
                % Some children of ax may not have XData etc. fields, but
                % there is no way to test for that. In particular,
                % isfield() always returns false for graphics handles, and
                % there is no equivalent that works. So we must attempt to
                % access the fields and ignore exceptions.
            end
        end
    end
    
    bbox = unionBbox( axisBbox, dataBbox );
    
    if isfield( s, 'centre' )
        if isempty( s.centre )
            bboxCentre = sum(bbox,1)/2;
        elseif isnumeric(s.centre)
            bboxCentre = s.centre;
        else
            switch s.centre
                case 'target'
                    bboxCentre = get( theaxes,'CameraTarget' );
                case 'origin'
                    bboxCentre = [0 0 0];
                otherwise
                    bboxCentre = sum(bbox,1)/2;
            end
        end
        bbox1 = bbox - bboxCentre;
        bboxOffset = max(abs(bbox1),[],1);
        if isfield( s, 'relmargin') && ~isempty( s.relmargin )
            bboxOffset = bboxOffset * (1 + s.relmargin);
        end
        if isfield( s, 'absmargin') && ~isempty( s.absmargin )
            bboxOffset = bboxOffset + s.absmargin;
        end
        bbox = bboxCentre + [ -bboxOffset; bboxOffset ];
    end
end
