function camParams = cameraParamsFromOurViewParams( viewParams )
%camParams = cameraParamsFromOurViewParams( viewParams )
%   Convert our camera parameters to Matlab's.
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
%
%   See also: ourViewParamsFromCameraParams.

    camParams.CameraViewAngle = viewParams.fov;
    camParams.Projection = viewParams.projection;

    az = viewParams.azimuth*pi/180;
    el = viewParams.elevation*pi/180;
    roll = viewParams.roll*pi/180;
    cosaz = cos(az);
    sinaz = sin(az);
    camright = [ cosaz, sinaz, 0 ];
    cosel = cos(el);
    sinel = sin(el);
    camlook = [ -sinaz*cosel, cosaz*cosel, -sinel ];
    cosroll = cos(roll);
    sinroll = sin(roll);
    camup = [ -sinaz*sinel, cosaz*sinel, cosel ];
    rollcamup = camup*cosroll - camright*sinroll;
    rollcamright = camup*sinroll + camright*cosroll;
    
    camParams.CameraUpVector = rollcamup;
    camParams.CameraTarget = - rollcamright*viewParams.pan(1) ...
                             - rollcamup*viewParams.pan(2) ...
                             + camlook*viewParams.targetdistance;
    camParams.CameraPosition = camParams.CameraTarget - camlook*viewParams.camdistance;
end

 