function m = meshSetCameraDistanceByBbox( m )
    [matlabCameraParams,databbox] = setCameraDistanceByBbox( m.pictures, 'bboxmode', 'data', 'relmargin', 0.1 );
    if ~isempty( matlabCameraParams )
        m.plotdefaults.matlabViewParams = matlabCameraParams;
        m.plotdefaults.ourViewParams = ourViewParamsFromCameraParams( matlabCameraParams );
        axbboxOutset = [-1 -1 -1;1 1 1] * 0.5;
        axbbox = databbox + axbboxOutset;
        axis( m.pictures, axbbox(:)' );
        timedFprintf( 'Camera distance set to %g.\n', norm( matlabCameraParams.CameraPosition - matlabCameraParams.CameraTarget ) );
    end
end
