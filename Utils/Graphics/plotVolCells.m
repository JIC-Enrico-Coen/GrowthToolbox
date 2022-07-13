function [h_pts,h_edges,h_faces] = plotVolCells( ax, volcells, varargin )
    [plotoptions,ok] = safemakestruct( mfilename(), varargin );
    plotoptions = defaultfields( plotoptions, ...
        'MarkerSize', 30, ...
        'VertexColor', 'k', ...
        'EdgeColor', 'b', ...
        'FaceColor', 'g', ...
        'FaceAlpha', 0.5, ...
        'SurfaceOnly', false, ...
        'LineWidth', 1 );
    
    
    washold = beginhold( ax );
    
    % Plot vertexes.
    
    h_pts = plotpts( volcells.vxs3d, 'Parent', ax, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', plotoptions.MarkerSize, 'Color', plotoptions.VertexColor );
    
    % Plot edges.
    
    h_edges = plotlines( volcells.edgevxs, volcells.vxs3d, 'Parent', ax, 'LineStyle', '-', 'LineWidth', plotoptions.LineWidth, 'Color', plotoptions.EdgeColor );
    
    % Plot faces.
    
    if plotoptions.FaceAlpha > 0
        h_faces = plotpolys( ax, volcells.vxs3d, volcells.facevxs, 'FaceAlpha', plotoptions.FaceAlpha, 'FaceColor', 'c' );
    else
        h_faces = [];
    end
    
    
    sethold( ax, washold );
end
