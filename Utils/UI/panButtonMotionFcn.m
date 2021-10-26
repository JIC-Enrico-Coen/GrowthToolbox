function panButtonMotionFcn( hObject, ~ )
    ax = getUserdataField( hObject, 'clickDragItem' );
    clickData = getClickData( ax );
    if isempty( clickData ), return; end
    currentpoint = get( hObject, 'CurrentPoint' );
    delta = (currentpoint - clickData.startpoint) ...
            * clickData.axessizeunits/clickData.axessizepixels;
  % dp = (currentpoint - clickData.startpoint)
  % asp = clickData.axessizepixels
  % asu = clickData.axessizeunits
    camParams = getCameraParams( clickData.axes );
    [~, cameraUp, cameraRight] = cameraFrame( camParams );
    offset = delta(1)*cameraRight + delta(2)*cameraUp;
    newcampos = clickData.startCameraPosition - offset;
    newcamtgt = clickData.startCameraTarget - offset;
    set( clickData.axes, ...
         'CameraPosition', newcampos, ...
         'CameraTarget', newcamtgt );
    gd = guidata( hObject );
    if isfield( gd, 'stereodata' )
        stereoTransfer( gd.stereodata.otheraxes, ...
                        newcampos, ...
                        newcamtgt, ...
                        cameraUp, ...
                        gd.stereodata.vergence );
    end
    clickData.moved = true;
    setClickData( clickData );
end

