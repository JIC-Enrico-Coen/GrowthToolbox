function povrayParams = povrayParamsFromOurViewParams( viewParams )
%povrayParams = povrayParamsFromOurViewParams( viewParams )
%   Convert our camera parameters to POV-Ray's.
%   POV-Ray's camera parameters are:
%     perspective|orthographic
%     location: a vector
%     look_at: a vector
%     right: a vector
%     up: a vector
%     direction: a vector
%   Our camera parameters are:
%       fov (field of view)
%       azimuth
%       elevation
%       roll
%       pan (two components)
%       targetdistance
%
%   See also: ourViewParamsFromCameraParams.

    viewwidth = 2*tan(viewParams.fov/2)*targetdistance;
    povrayParams.projection = viewParams.projection;

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
    
    povrayParams.right = camright*viewwidth
    povrayParams.up = camup;
    povrayParams.sky = rollcamup;
    povrayParams.look_at = - rollcamright*viewParams.pan(1) ...
                             - rollcamup*viewParams.pan(2) ...
                             + camlook*viewParams.targetdistance;
    povrayParams.location = povrayParams.look_at - camlook*viewParams.camdistance;
end

 