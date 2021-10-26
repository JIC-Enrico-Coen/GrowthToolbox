function [aniso,flatness,diameters,cellaxes,cellcentres] = plotCellEllipses( m )
    [aniso,flatness,diameters,cellaxes,cellcentres] = leaf_cellshapes( m );
    radii = diameters/2;
    numcells = length(aniso);
    t = linspace(0,pi*2,37)';
    t(end) = [];
    c = cos(t);
    s = sin(t);
    numpts = length(t);
    circle = [ c, s, zeros(size(t)) ];
    ax = m.pictures;
    hold(ax,'all');
    for i=1:numcells
        basis = cellaxes(:,:,i) .* repmat( radii(i,:), 3, 1 );
        cellellipse = circle*(basis') + repmat( cellcentres(i,:), numpts, 1 );
        plotpts( ax, cellellipse([1:end 1],:), 'LineWidth', 5 );
        c = cellcentres(i,:);
        xp = c + basis(:,1)';
        xm = c - basis(:,1)';
        yp = c + basis(:,2)';
        ym = c - basis(:,2)';
        zp = c + basis(:,3)';
        zm = c - basis(:,3)';
        plotpts( ax, [xm; xp], '.-', 'LineWidth', 5 );
        plotpts( ax, [ym; yp], '.-', 'LineWidth', 5 );
        plotpts( ax, [zm; zp], '.-', 'LineWidth', 5 );
    end
    hold(ax,'off');
end
