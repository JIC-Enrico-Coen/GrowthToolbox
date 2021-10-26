function figure_SpaceItems( parent, items, varargin ) % bbox, hn, vn, hsep, vsep, hmargin, vmargin )
%figure_SpaceItems( parent, items, bbox, vn, hsep, vsep, hmargin,
%vmargin )
% WORK IN PROGRESS
%
%   parent is a panel or a figure.
%   items is an array of handles to UI items.
%
%   The procedure lays out the items within the parent in a regular grid
%   according to the remaining parameters.
%
%   bbox is the bounding box of an area within the parent that the items
%   are to be placed.  If it is empty, it defaults to the full size of the
%   parent.
%   hn is the number vertically.
%   vn is the number vertically.
%   hsep is the horizontal space between items.
%   vsep is the vertical space between items.
%   hmargin is the horizontal space between items and the bounding box.
%   vmargin is the vertical space between items and the bounding box.

    if isempty(items), return; end
    nitems = length(items);

    options = struct( varargin{:} );
    % Allowed options are:
    %   bbox, bboxsize, bboxpos, hn, vn, hsep, vsep, hmargin, vmargin, hsz,
    %   vsz
    % Any subset of these can be given, and the procedure will fill in all
    % missing values, and find a compromise where supplied values conflict.
    
    % No bounding box size: implied by max size of any element and layout.
    % No bounding box position: top left of parent (plus a "MARGIN"
    % attribute?)
    % Too big: scale everything down proportionally.
    
    SEPARATION = 10;
    options = defaultFromStruct( options, ...
        struct( 'hmargin', SEPARATION, ...
                'vmargin', SEPARATION, ...
                'hsep', SEPARATION, ...
                'vsep', SEPARATION ) );
    havehn = isfield( options, 'hn' ) && (options.hn > 0);
    havevn = isfield( options, 'vn' ) && (options.vn > 0);
    if havehn ~= havevn
        if isfield( options, 'hn' )
            options.vn = ceil( nitems/options.hn );
        else
            options.hn = ceil( nitems/options.vn );
        end
    elseif ~havehn
        options.hn = 1;
        options.vn = nitems;
    end
    
    
    
    if isempty(items), return; end
    if (~isfield( options, 'bbox' )) || isempty(options.bbox)
        options.bbox = get( parent, 'Position' );
        options.bbox(1:2) = [0 0];
    end
    options
                
    nitems = length(items);
    hstep = (options.bbox(3) - options.hmargin*2 + options.hsep)/options.hn;
    hsz = hstep - options.hsep;
    vstep = (options.bbox(4) - options.vmargin*2 + options.vsep)/options.vn;
    vsz = vstep - options.vsep;
    i = 0;
    hpos = options.hmargin;
    vstart = options.bbox(4) - options.vmargin - vsz;
    vpos = vstart;
    while i < nitems
        i = i+1;
        set( items(i), 'Parent', parent, 'Position', [hpos, vpos, hsz, vsz] );
        if mod(i,options.vn)==0
            vpos = vstart;
            hpos = hpos + hstep;
        else
            vpos = vpos - vstep;
        end
    end
end
