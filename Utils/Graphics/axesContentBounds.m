function axisBounds = axesContentBounds( ax )
    axisBounds = [];
    if ~ishghandle(ax)
        axisBounds = [];
        return;
    end
    
    for i=1:length(ax.Children)
        h = ax.Children(i);
        switch h.Type
            case { 'surface', 'line' }
                ab = [ min(h.XData), max(h.XData), min(h.YData), max(h.YData), min(h.ZData), max(h.ZData) ];
                axisBounds = combineAxisBounds( axisBounds, ab );
            case 'patch'
                ab = reshape( [ min( h.Vertices, [], 1 ); max( h.Vertices, [], 1) ], 1, [] );
                axisBounds = combineAxisBounds( axisBounds, ab );
            otherwise
        end
    end
end

