function m = rectifyMeshFOV( m, fov )
%m = rectifyMeshFOV( m, fov )
%   Set the field of view to the given value (default 10 degrees), and
%   adjust the camera distance so that in orthographic projection, the
%   visible scene remains unchanged.  In perspective projection, the
%   intersection of the view frustum with the target plane will remain
%   unchanged.

global gMatlabViewParams

    if nargin < 2
        fov = gMatlabViewParams.CameraViewAngle;
    end
    m.plotdefaults.ourViewParams = ...
        rectifyFOV_OVP( m.plotdefaults.ourViewParams, fov );
    m.plotdefaults.matlabViewParams = ...
        rectifyFOV_MVP( m.plotdefaults.matlabViewParams, fov );
end
