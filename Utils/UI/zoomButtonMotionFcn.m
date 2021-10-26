function zoomButtonMotionFcn( hObject, ~ )
    ax = getUserdataField( hObject, 'clickDragItem' );
    clickData = getClickData( ax );
    if isempty( clickData ), return; end
    if ~isfield( clickData, 'startpoint' ), return; end
    currentpoint = get( hObject, 'CurrentPoint' );
    ZOOMSCALING = 5;
    delta = (currentpoint - clickData.startpoint) ...
            * ZOOMSCALING/clickData.axessizepixels;
    camParams = getCameraParams( clickData.axes );
    [~, cameraUp, ~] = cameraFrame( camParams );
    newviewangle = trimnumber( 0, ...
                       clickData.startCameraViewAngle * zoomScale( delta(2) ), ...
                       179.0 );
    set( clickData.axes, ...
         'CameraViewAngle', newviewangle );

    gd = guidata( hObject );
    if isfield( gd, 'stereodata' )
        stereoTransfer( gd.stereodata.otheraxes, ...
                        camParams.CameraPosition, ...
                        camParams.CameraTarget, ...
                        cameraUp, ...
                        gd.stereodata.vergence );
    end
    if isfield( gd, 'mesh' )
        setscalebarsize( gd.mesh );
    end
    clickData.moved = true;
    setClickData( clickData );
end

function zs = zoomScale( delta )
    zs = (delta + sqrt( delta*delta+4 ))/2;
end

