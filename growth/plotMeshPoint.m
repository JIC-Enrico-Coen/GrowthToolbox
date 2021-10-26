function h = plotMeshPoint( position, highlighted )
% NEVER USED
    if highlighted
        sz = 3;
    else
        sz = 1;
    end
    h = line( position(1), position(2), position(3), ...
          'Color', 'k', 'LineStyle', 'none', 'LineWidth', sz, 'Marker', 'o' );
          ... % 'LineSmoothing','on', ...  % LineSmoothing is deprecated.
end
