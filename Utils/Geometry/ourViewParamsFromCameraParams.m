function viewParams = ourViewParamsFromCameraParams( camParams )
%viewParams = ourViewParamsFromCameraParams( camParams )
%   Convert Matlab's camera parameters to ours.
%   camParams may be either an axes handle or a struct containing Matlab's
%   camera parameters.
%
%   Matlab's camera parameters are:
%       CameraViewAngle
%       CameraTarget
%       CameraPosition
%       CameraUpVector
%   Our camera parameters are:
%       fov (field of view)
%       azimuth
%       elevation
%       roll
%       pan (two components)
%       targetdistance
%       camdistance
%
%   targetdistance is the distance of the target point behind the plane
%   through the origin perpendicular to the view direction.
%   camdistance is the distance of the camera from the target point.
%
%   See also: cameraParamsFromOurViewParams.

    if ishandle( camParams )
        camParams = getCameraParams( camParams );
    end

    viewParams.fov = camParams.CameraViewAngle;
    viewParams.projection = camParams.Projection;
    
    [cameraLook, cameraUp, cameraRight] = cameraFrame( ...
        camParams.CameraPosition, camParams.CameraTarget, camParams.CameraUpVector );
    
    HORIZ_TOLERANCE = eps(20);
    verticalView = max( abs( cameraLook([1 2]) ) ) < HORIZ_TOLERANCE;
    if verticalView
        cameraHorizRight = cameraRight;
    else
        cameraHorizRight = [ cameraLook(2), -cameraLook(1), 0 ];
    end
    if all(cameraHorizRight==0)
        cameraHorizRight = cameraRight;
    else
        cameraHorizRight = cameraHorizRight/norm(cameraHorizRight);
    end
    
    camxy = sqrt( cameraLook(1)^2 + cameraLook(2)^2 );
    if verticalView
        viewParams.azimuth = atan2( -cameraUp(1), cameraUp(2) ) * 180/pi;
        viewParams.elevation = -90 * sign( cameraLook(3) );
        viewParams.roll = 0;
    else
        viewParams.azimuth = atan2( -cameraLook(1), cameraLook(2) ) * 180/pi;
        viewParams.elevation = atan2( -cameraLook(3), camxy ) * 180/pi;
        viewParams.roll = atan2( -dot(cameraUp,cameraHorizRight), ...
               dot(cross(cameraUp,cameraHorizRight),cameraLook) ) * 180/pi;
    end
    camunitvertical = cross( cameraRight, cameraLook );
    camlookVector = camParams.CameraTarget - camParams.CameraPosition;
    viewParams.targetdistance = dot( camParams.CameraTarget, cameraLook );
    viewParams.pan = [ -dot( camParams.CameraPosition, cameraRight ), ...
                       -dot( camParams.CameraPosition, camunitvertical ) ];
    viewParams.camdistance = norm( camlookVector );
end

 