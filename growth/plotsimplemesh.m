function plotsimplemesh( ax, nodes, edgeends, edgevalues )
    plotpts( ax, nodes, 'ok' );
    hold( ax, 'on' );
    if nargin==2
        plotlines( edgeends, nodes, 'Parent', ax, '-k' );
    else
        if (nargin < 4) || (min(edgevalues)==max(edgevalues))
            plotlines( edgeends, nodes, 'Parent', ax, 'LineStyle', '-', 'Marker', 'non', 'Color', 'k' );
        else
            maxev = max(abs(edgevalues(:)));
            ev = edgevalues/maxev;
            hues = zeros( numel(ev), 1 );
            hues( ev<0 ) = 2/3;
            ev = abs(ev(:));
            minval = 0.8;
            hsvs = [ hues, ev, ev*(1-minval)+minval ];
          % hsvs = [ hues, ones( length(hues), 2 ) ];
            plotcolouredlines( ax, nodes, edgeends, hsv2rgb( hsvs ), 'LineWidth', 2 );
        end
        axis(ax,'equal');
    end
    hold( ax, 'off' );
end

