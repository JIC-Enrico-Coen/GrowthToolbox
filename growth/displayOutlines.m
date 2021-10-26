function displayOutlines( m )
%displayOutlines( m )
%   Display the outlines of the flattened connected components of m.

    [nodeindexes,nodesets] = connectedComponentsE(m);
    numcpts = length(nodesets);
    np = ceil(sqrt(numcpts));
    figure(1);
    for i=1:numcpts
        nsi = nodesets{i}
        [bn,ba,be] = componentBoundary( m, nsi(1) );
        vxs = layOutPolygon(be,ba);
        subplot( np, np, i );
        plotpts( gca, [ vxs; vxs(1,:) ], 'o-' );
        axis equal
        if i==6
            x = 1;
        end
    end
end
