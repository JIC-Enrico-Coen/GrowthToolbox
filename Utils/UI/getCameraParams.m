function cp = getCameraParams( theaxes )
    cp = struct( ...
        'CameraPosition', get( theaxes,'CameraPosition' ), ...
        'CameraTarget', get( theaxes,'CameraTarget' ), ...
        'CameraUpVector', get( theaxes,'CameraUpVector' ), ...
        'CameraViewAngle', get( theaxes,'CameraViewAngle' ), ...
        'Projection', get( theaxes,'Projection' ) );
end
