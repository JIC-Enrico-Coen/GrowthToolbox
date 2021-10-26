function testcapsuleApproachToDistance2()
    d0 = 0.3;
    fig = figure();
    while true
        [p01,q01] = getRandomExample( 1 );
        [pbc1,qbc1,pbcx,qbcx,d,collision,collisiontype] = capsuleApproachToDistance2( p01, q01, d0 );
        fprintf( 1, 'collision %s, type %s, dist %f\n', boolchar( collision ), collisiontype, d );
        fprintf( 1, 'p [%f %f %f; %f %f %f]\nq [%f %f %f; %f %f %f]\n', p01', q01' );
        fprintf( 1, 'pbc1 [%f %f] [%f %f %f]\n', pbc1, pbc1*p01 );
        fprintf( 1, 'qbc1 [%f %f] [%f %f %f]\n', qbc1, qbc1*q01 );
        fprintf( 1, 'pbcx [%f %f] [%f %f %f]\n', pbcx, pbcx*p01 );
        fprintf( 1, 'qbcx [%f %f] [%f %f %f]\n', qbcx, qbcx*q01 );
        drawData( fig, p01, q01, d, pbc1, qbc1, pbcx, qbcx, collision, collisiontype );
        drawnow;
        pause;
    end
end

function [p01,q01] = getRandomExample( type )
    switch type
        case 1
            p01 = rand(2,3);
            q01 = rand(2,3);
        case 2
            p01 = [ rand(2,2), [0.1;0.1] ];
            q01 = [ rand(2,2), [0.1;0.1] ];
    end
end


function drawData( fig, p01, q01, d, pbc1, qbc1, pbcx, qbcx, collision, collisiontype )
    endpointsize = 15;
    collisionsize = 30;
    if collision
        collisionmark = '.';
    else
        collisionmark = 'x';
    end
    ppt1 = pbc1*p01;
    qpt1 = qbc1*q01;
    pptx = pbcx*p01;
    qptx = qbcx*q01;
    set( 0, 'CurrentFigure', fig );
    cla;
    hold on
    plotpts( p01, '-r' );
    plotpts( p01(1,:), '.-k', 'Markersize', endpointsize );
    plotpts( p01(2,:), '.-r', 'Markersize', endpointsize );
    plotpts( q01, '.-b' );
    plotpts( q01(1,:), '.-k', 'Markersize', endpointsize );
    plotpts( q01(2,:), '.-b', 'Markersize', endpointsize );
    plotpts( ppt1, '.-g', 'Markersize', collisionsize, 'Marker', collisionmark );
    plotpts( qpt1, '.-c', 'Markersize', collisionsize, 'Marker', collisionmark );
    plotpts( pptx, '.-g', 'Markersize', 10, 'Marker', 'o' );
    plotpts( qptx, '.-c', 'Markersize', 10, 'Marker', 'o' );
    if ~any( isinf( [ppt1 qpt1] ) ) && ~all(qbc1==0)
        plotpts( [ppt1;qpt1], 'LineStyle', '--', 'Marker', 'none' );
    end
    hold off
    axis equal
    axis( [0 1 0 1 0 1] );
end
