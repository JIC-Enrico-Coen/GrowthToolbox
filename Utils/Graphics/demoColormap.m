function demoColormap( varargin )
%demoColormap( colors, ... )
%   Demonstrate a color map in a horizontal rectangle.
%
%demoColormap( ax, colors, ... )
%   Plot into the given axes object AX.
%
%   Options:
%
%   shading: Either 'flat' or 'smooth'. The default is smooth.
%
%   positions: The positions, along a scale of 0 to 1, to be mapped to each
%       color. There must be the same number of positions as colors. They
%       should be in ascending order. By default the positions are chosen
%       to divide the interval into equal steps. For smooth shading the
%       first should be 0 and the last should be 1. For flat shading the
%       positions are assumed to locate the left-hand edge of each tile.
%       The first should be 0 and the last will normally be less than 1.
%
%   The rectangle will be drawn framed with a black border, and with tick
%   marks on the bottom edge at the positions.

    if (numel(varargin{1})==1) && ishghandle(varargin{1})
        ax = varargin{1};
        varargin(1) = [];
    else
        ax = gca();
    end
    colors = varargin{1};
    varargin(1) = [];
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'shading', 'smooth', 'positions', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'shading', 'positions' );
    if ~ok, return; end
    
    numcolors = size(colors,1);
    if numcolors==1
        s.shading = 'flat';
    end
    
    switch s.shading
        case 'smooth'
            flat = false;
        case 'flat'
            flat = true;
        otherwise
            timedFprintf( '''shading'' option must be either ''flat'' or ''smooth'', ''%s'' found.\n', s.shading );
            return;
    end
    
    if ~isempty( s.positions )
        if numel( s.positions ) ~= numcolors
            timedFprintf( 'There must be the same number of positions as colors. %d colors supplied, %d positions given.\n', ...
                numcolors, numel(s.positions) );
            return;
        end
    end
    
    s.positions = sort( s.positions(:) );
    
    if flat
        if isempty( s.positions )
            xs = linspace( 0, 1, numcolors+1 )';
        else
            xs = [ s.positions; 1 ];
        end
    else
        if isempty( s.positions )
            if numcolors==1
                xs = 0;
            else
                xs = linspace( 0, 1, numcolors )';
            end
        else
            xs = s.positions(:);
        end
    end
    xs(end) = max(xs(end),1);
    xs(1) = min(xs(1),0);
    xs = max(xs,0);
    xs = min(xs,1);
    ys = [0 0.25];
    numxs = length(xs);
    numtiles = numxs-1;
    
    vxs = [ repmat( xs, length(ys), 1 ), reshape( repmat( ys, length(xs), 1 ), [], 1 ) ];
    
    corner1 = (1:numtiles)';
    corner2 = corner1+1;
    corner4 = corner1+numxs;
    corner3 = corner4+1;
    faces = [ corner1 corner2 corner3 corner4 ];
    
    cla( ax );
    if flat
        cs = (1:numtiles)';
        h = patch('Parent',ax,'Faces',faces,'Vertices',vxs,'FaceVertexCData',cs,'FaceColor','flat','EdgeColor','none','EdgeColor','none');
        colormap( colors );
    else
        cs = repmat( (1:numxs)', 2, 1 );
        h = patch('Parent',ax,'Faces',faces,'Vertices',vxs,'FaceVertexCData',colors(cs,:),'FaceColor','interp','EdgeColor','none');
%         colormap( colors ); % I find that setting the colormap causes
            %  flat shading, even when the FaceVertexCData are per-vertex.
    end
    line( xs( [1 end end 1 1] ), ys( [1 1 end end 1] ), 'Parent', ax, 'Color', 'k', 'LineWidth', 1 );
    if numxs >= 3
        tickx = xs'; % linspace( 0, 1, numxs );
        tickx([1 end]) = [];
        ticklen = 0.1 * max(ys);
        tickxs = reshape( [ tickx; tickx; NaN(1,length(tickx)) ], [], 1 );
        tickys = reshape( [ zeros(1,length(tickx)); zeros(1,length(tickx))+ticklen;  NaN(1,length(tickx)) ], [], 1 );
        h = line( tickxs, tickys, 'Parent', ax, 'Color', 'k', 'LineWidth', 1 );
    end
    
    ax.XTick = [];
    ax.YTick = [];
    ax.ZTick = [];
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    ax.ZAxis.Visible = 'off';
    axis(ax,'equal');
    axis(ax,'tight');
end
