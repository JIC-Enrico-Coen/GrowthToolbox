function mesh = getPlotOptionsFromDialog( mesh, handles )
    if isempty( handles.mesh ), return; end
    
    queuedchanges = get( handles.plotFlag, 'UserData' );
    if ~isempty( queuedchanges )
        mesh.plotdefaults = setFromStruct( mesh.plotdefaults, queuedchanges );
    end

    mesh.globalProps.displayedGrowth = getDisplayedMgenIndex( handles );

    az = -get( handles.azimuth, 'Value' );
    if isempty( az )
        az = gOurViewParams.azimuth;
        set( handles.azimuth, 'Value', -az );
    end
    el = -get( handles.elevation, 'Value' );
    if isempty( el )
        el = gOurViewParams.elevation;
        set( handles.elevation, 'Value', -el );
    end
    roll = -get( handles.roll, 'Value' );
    if isempty( roll )
        roll = gOurViewParams.roll;
        set( handles.roll, 'Value', -roll );
    end
    mesh.plotdefaults.azimuth = az;
    mesh.plotdefaults.elevation = el;
    mesh.plotdefaults.roll = roll;
    mesh.plotdefaults.ourViewParams.azimuth = az;
    mesh.plotdefaults.ourViewParams.elevation = el;
    mesh.plotdefaults.ourViewParams.roll = roll;
    mesh.plotdefaults.matlabViewParams = ...
        cameraParamsFromOurViewParams( mesh.plotdefaults.ourViewParams );
    
    mesh.plotdefaults.monocolors = [];
end
