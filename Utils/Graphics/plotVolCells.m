function [h_pts,h_edges,h_faces] = plotVolCells( ax, volcells, varargin )
    [plotoptions,ok] = safemakestruct( mfilename(), varargin );
    plotoptions = defaultfields( plotoptions, ...
        'MarkerSize', 10, ...
        'VertexColor', 'k', ...
        'EdgeColor', 'b', ...
        'FaceColor', 'g', ...
        'FaceAlpha', 0.8, ...
        'SurfaceOnly', false, ...
        'LineWidth', 1 );
    
    if isfield( plotoptions, 'cells' )
        cells = plotoptions.cells;
        plotoptions = rmfield( plotoptions, 'cells' );
    else
        cells = 1:length(volcells.polyfaces);
    end
    
    faces = unique( cell2mat( volcells.polyfaces(cells) ) );
    edges = unique( cell2mat( volcells.faceedges(faces) ) );
    vxs = unique( reshape( volcells.edgevxs(edges,:), [], 1 ) );
    
    washold = beginhold( ax );
    
    % Plot vertexes.
    
    h_pts = plotpts( volcells.vxs3d(vxs,:), 'Parent', ax, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', plotoptions.MarkerSize, 'Color', plotoptions.VertexColor );
    
    % Plot edges.
    
    h_edges = plotlines( volcells.edgevxs(edges,:), volcells.vxs3d, 'Parent', ax, 'LineStyle', '-', 'LineWidth', plotoptions.LineWidth, 'Color', plotoptions.EdgeColor );
    
    % Plot faces.
    
    if plotoptions.FaceAlpha > 0
        h_faces = plotpolys( ax, volcells.vxs3d, volcells.facevxs(faces), 'FaceAlpha', plotoptions.FaceAlpha, 'FaceColor', 'c' );
    else
        h_faces = [];
    end
    
    
    sethold( ax, washold );
end
