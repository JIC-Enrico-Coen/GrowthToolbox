function cp = getCameraParams( theaxes )
%cp = getCameraParams( theaxes )
%   Get the Matlab camera parameters by reading them directly from the
%   relevant fields of THEAXES. These are:
%       CameraPosition  vector
%       CameraTarget    vector
%       CameraUpVector  vector
%       CameraViewAngle scalar, in degrees.
%       Projection      string, either 'orthographic' or 'perspective'

    cp = struct( ...
        'CameraPosition', get( theaxes,'CameraPosition' ), ...
        'CameraTarget', get( theaxes,'CameraTarget' ), ...
        'CameraUpVector', get( theaxes,'CameraUpVector' ), ...
        'CameraViewAngle', get( theaxes,'CameraViewAngle' ), ...
        'Projection', get( theaxes,'Projection' ) );
end
