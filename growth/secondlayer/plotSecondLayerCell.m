function ph = plotSecondLayerCell( ci, cellpts, cellcolor, theaxes )
% NOT USED
%ph = plotSecondLayerCell( ci, cellpts, ax, cellcolor )
%   Plot a single cell of the second layer and return its handle.
%   Arguments are the index of the cell, its vertexes, and its colour.

    faceedgecol = [0.2 0.2 0.2];
    alpha = 1;
    ph = patch( cellpts(:,1), cellpts(:,2), cellpts(:,3), ...
        cellcolor, ...
        'FaceAlpha', alpha, ...
        'EdgeColor', faceedgecol, ...
        'UserData', struct( 'biocell', ci ), ...
        'LineStyle', 'none', ...
        'LineWidth', 1, ...
        'Parent', theaxes ...
    );
end
