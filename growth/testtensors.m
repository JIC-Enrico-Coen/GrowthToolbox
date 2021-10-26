function testtensors()
    testtensor( 1.2, 1.1, 0.5 );
    testtensor( 1, 0, 0.1 );
    testtensor( 4, 3, 0.1 );
end

function testtensor( major, minor, theta )
    gt = growthTensorFromParams( major, minor, theta );
    [ major1, minor1, theta1 ] = growthParamsFromTensor( gt );
    fprintf( 1, '(%f %f %f)\n', major, minor, theta );
    fprintf( 1, '    (%f %f %f)\n', gt(1), gt(2), gt(6) );
    fprintf( 1, '(%f %f %f)\n', major1, minor1, theta1 );
end
