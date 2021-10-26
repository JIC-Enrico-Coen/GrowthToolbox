function handles = updateAziElScrollFromView( handles )
    [az,el,roll] = getview( handles.picture );
    az = normaliseAngle( az, -180 );
    safesetgh( handles, 'azimuth', 'Value', -az );
    safesetgh( handles, 'elevation', 'Value', -el );
    safesetgh( handles, 'roll', 'Value', -roll );
    announceview( handles, az, el, roll );
    if ~isempty( handles.mesh )
        handles.mesh.plotdefaults.azimuth = az;
        handles.mesh.plotdefaults.elevation = el;
        handles.mesh.plotdefaults.roll = roll;
        handles.mesh.plotdefaults.ourViewParams.azimuth = az;
        handles.mesh.plotdefaults.ourViewParams.elevation = el;
        handles.mesh.plotdefaults.ourViewParams.roll = roll;
        handles.mesh.plotdefaults.matlabViewParams = ...
            cameraParamsFromOurViewParams( handles.mesh.plotdefaults.ourViewParams );
    end
end
