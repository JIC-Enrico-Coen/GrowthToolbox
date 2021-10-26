function [alts,ratios,pos] = triAltitudes( vxs )
    [a1,alt1,foot1,pos] = altitudeTriangle2D( vxs );
    [a2,alt2,foot2] = altitudeTriangle2D( vxs([2,3,1],:) );
    [a3,alt3,foot3] = altitudeTriangle2D( vxs([3,1,2],:) );
    alts = [alt1;alt2;alt3];
    ratios = [a1; a2; a3];
    return;
    
    clf;
    hold on;
    plotpts( vxs([1 2 3 1],:), 'o-k' );
    plotlines( [[1 4];[2 5];[3 6]], [vxs;(vxs-alts)], '-' );
    hold off
    axis equal
    drawnow
end
