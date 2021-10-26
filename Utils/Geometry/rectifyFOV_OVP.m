function ourViewParams = rectifyFOV_OVP( ourViewParams, newfov )
%ourViewParams = rectifyFOV_OVP( ourViewParams, newfov )
%   Set the field of view angle, and change the camera distance so that in
%   orthographic projection, the visible appearance of the scene is
%   unchanged.  This computation is carried out in terms of our view
%   parameters.
%   newfov is given in degrees.

    oldfov = ourViewParams.fov;
    ourViewParams.fov = newfov;
    ourViewParams.camdistance = ourViewParams.camdistance * ...
        tan(oldfov*pi/360)/tan(newfov*pi/360);
end
